// Puente JNI minimo entre Kotlin y llama.cpp para ejecutar LFM2 (GGUF) dentro del celular.
#include <jni.h>
#include <android/log.h>

#include <algorithm>
#include <atomic>
#include <mutex>
#include <string>
#include <vector>

#include "llama.h"

#define LOG_TAG "AiessLlm"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

namespace {
std::mutex g_mutex;
llama_model *g_model = nullptr;
llama_context *g_ctx = nullptr;
const llama_vocab *g_vocab = nullptr;
std::atomic<bool> g_stop{false};
bool g_backend = false;
// Cache del prefijo fijo (prompt de sistema): se procesa una vez y se restaura en cada analisis.
std::vector<llama_token> g_pref_toks;
std::vector<uint8_t> g_pref_estado;

void liberar_locked() {
    if (g_ctx) { llama_free(g_ctx); g_ctx = nullptr; }
    if (g_model) { llama_model_free(g_model); g_model = nullptr; }
    g_vocab = nullptr;
    g_pref_toks.clear();
    g_pref_estado.clear();
}

// Longitud del prefijo que es UTF-8 completo (no corta caracteres a la mitad).
size_t prefijo_utf8_valido(const std::string &s) {
    size_t i = s.size();
    size_t retro = 0;
    while (i > 0 && retro < 4) {
        unsigned char c = static_cast<unsigned char>(s[i - 1]);
        if ((c & 0xC0) == 0x80) { --i; ++retro; continue; }
        size_t esperado = (c & 0x80) == 0 ? 1 : (c & 0xE0) == 0xC0 ? 2 : (c & 0xF0) == 0xE0 ? 3 : 4;
        return (retro + 1 >= esperado) ? s.size() : i - 1;
    }
    return s.size();
}

jbyteArray a_bytes(JNIEnv *env, const std::string &s) {
    jbyteArray arr = env->NewByteArray(static_cast<jsize>(s.size()));
    env->SetByteArrayRegion(arr, 0, static_cast<jsize>(s.size()), reinterpret_cast<const jbyte *>(s.data()));
    return arr;
}

void poner_tokens(llama_batch_ext *batch, const llama_token *toks, int32_t n, llama_pos pos0, bool logits_final) {
    llama_batch_ext_clear(batch);
    for (int32_t i = 0; i < n; ++i) {
        const int32_t idx = llama_batch_ext_add_token(batch, 0, toks[i]);
        const llama_pos pos = pos0 + i;
        llama_batch_ext_set_pos(batch, idx, &pos);
    }
    if (logits_final) llama_batch_ext_set_output_logits(batch, n - 1, true);
}
}  // namespace

extern "C" JNIEXPORT jboolean JNICALL
Java_ec_aiess_aiess_LlmBridge_cargar(JNIEnv *env, jobject, jstring jruta, jint n_ctx, jint n_hilos) {
    std::lock_guard<std::mutex> lock(g_mutex);
    if (!g_backend) { llama_backend_init(); g_backend = true; }
    liberar_locked();
    const char *ruta = env->GetStringUTFChars(jruta, nullptr);
    llama_model_params mp = llama_model_default_params();
    mp.n_gpu_layers = 0;
    g_model = llama_model_load_from_file(ruta, mp);
    env->ReleaseStringUTFChars(jruta, ruta);
    if (!g_model) { LOGE("no se pudo cargar el modelo"); return JNI_FALSE; }
    llama_context_params cp = llama_context_default_params();
    cp.n_ctx = static_cast<uint32_t>(n_ctx);
    cp.n_batch = 512;
    cp.n_threads = n_hilos;
    cp.n_threads_batch = n_hilos;
    g_ctx = llama_init_from_model(g_model, cp);
    if (!g_ctx) { LOGE("no se pudo crear el contexto"); liberar_locked(); return JNI_FALSE; }
    g_vocab = llama_model_get_vocab(g_model);
    LOGI("modelo cargado, n_ctx=%d hilos=%d", n_ctx, n_hilos);
    return JNI_TRUE;
}

extern "C" JNIEXPORT jbyteArray JNICALL
Java_ec_aiess_aiess_LlmBridge_generar(JNIEnv *env, jobject, jstring jprompt, jstring jprefijo, jint max_tokens,
                                       jfloat temp, jobject callback) {
    std::lock_guard<std::mutex> lock(g_mutex);
    if (!g_ctx) return a_bytes(env, "");
    g_stop = false;

    jclass cb_cls = env->GetObjectClass(callback);
    jmethodID on_token = env->GetMethodID(cb_cls, "onToken", "([B)V");

    const char *p = env->GetStringUTFChars(jprompt, nullptr);
    std::string prompt(p);
    env->ReleaseStringUTFChars(jprompt, p);

    // El prompt ya trae el formato de chat de LFM2 (con <|startoftext|>), por eso add_special=false.
    const int n_prompt = -llama_tokenize(g_vocab, prompt.c_str(), (int32_t) prompt.size(), nullptr, 0, false, true);
    std::vector<llama_token> toks(n_prompt);
    llama_tokenize(g_vocab, prompt.c_str(), (int32_t) prompt.size(), toks.data(), n_prompt, false, true);

    const int n_ctx = (int) llama_n_ctx(g_ctx);
    if (n_prompt + max_tokens > n_ctx) {
        LOGE("prompt demasiado largo: %d tokens", n_prompt);
        return a_bytes(env, "");
    }

    // Prefijo fijo (system prompt): tokens del prefijo que coinciden con el inicio del prompt.
    const char *pf = env->GetStringUTFChars(jprefijo, nullptr);
    std::string prefijo(pf);
    env->ReleaseStringUTFChars(jprefijo, pf);
    int n_pref = 0;
    if (!prefijo.empty() && prompt.compare(0, prefijo.size(), prefijo) == 0) {
        const int np = -llama_tokenize(g_vocab, prefijo.c_str(), (int32_t) prefijo.size(), nullptr, 0, false, true);
        if (np > 0 && np < n_prompt) {
            std::vector<llama_token> pt(np);
            llama_tokenize(g_vocab, prefijo.c_str(), (int32_t) prefijo.size(), pt.data(), np, false, true);
            if (std::equal(pt.begin(), pt.end(), toks.begin())) n_pref = np;
        }
    }

    llama_memory_clear(llama_get_memory(g_ctx), true);
    llama_batch_ext *batch = llama_batch_ext_init(g_ctx);
    const int n_batch = (int) llama_n_batch(g_ctx);
    auto procesar = [&](int desde, int hasta, bool logits_final) -> bool {
        for (int i = desde; i < hasta; i += n_batch) {
            const int n = std::min(n_batch, hasta - i);
            poner_tokens(batch, toks.data() + i, n, i, logits_final && i + n >= hasta);
            if (llama_process(g_ctx, LLAMA_PROCESS_TYPE_DECODE, batch) != 0) return false;
        }
        return true;
    };

    int inicio = 0;
    if (n_pref > 0) {
        const bool mismo = !g_pref_estado.empty() && g_pref_toks.size() == (size_t) n_pref &&
                           std::equal(g_pref_toks.begin(), g_pref_toks.end(), toks.begin());
        if (mismo && llama_state_seq_set_data(g_ctx, g_pref_estado.data(), g_pref_estado.size(), 0) > 0) {
            inicio = n_pref;  // prefijo restaurado desde la cache: no se vuelve a calcular
        } else if (procesar(0, n_pref, false)) {
            g_pref_toks.assign(toks.begin(), toks.begin() + n_pref);
            g_pref_estado.resize(llama_state_seq_get_size(g_ctx, 0));
            llama_state_seq_get_data(g_ctx, g_pref_estado.data(), g_pref_estado.size(), 0);
            inicio = n_pref;
        } else {
            llama_memory_clear(llama_get_memory(g_ctx), true);
        }
    }
    if (!procesar(inicio, n_prompt, true)) {
        LOGE("fallo al procesar el prompt");
        llama_batch_ext_free(batch);
        return a_bytes(env, "");
    }

    llama_sampler *smpl = llama_sampler_chain_init(llama_sampler_chain_default_params());
    llama_sampler_chain_add(smpl, llama_sampler_init_penalties(llama_vocab_n_tokens(g_vocab), 64, 1.05f, 0.0f, 0.0f));
    if (temp <= 0.0f) {
        llama_sampler_chain_add(smpl, llama_sampler_init_greedy());
    } else {
        llama_sampler_chain_add(smpl, llama_sampler_init_min_p(0.15f, 1));
        llama_sampler_chain_add(smpl, llama_sampler_init_temp(temp));
        llama_sampler_chain_add(smpl, llama_sampler_init_dist(LLAMA_DEFAULT_SEED));
    }

    std::string salida, pendiente;
    int pos = n_prompt;
    for (int i = 0; i < max_tokens && !g_stop; ++i) {
        llama_token t = llama_sampler_sample(smpl, g_ctx, -1);
        if (llama_vocab_is_eog(g_vocab, t)) break;
        char buf[256];
        int n = llama_token_to_piece(g_vocab, t, buf, sizeof(buf), 0, false);
        if (n > 0) {
            pendiente.append(buf, n);
            size_t ok = prefijo_utf8_valido(pendiente);
            if (ok > 0) {
                std::string trozo = pendiente.substr(0, ok);
                pendiente.erase(0, ok);
                salida += trozo;
                jbyteArray arr = a_bytes(env, trozo);
                env->CallVoidMethod(callback, on_token, arr);
                env->DeleteLocalRef(arr);
            }
        }
        poner_tokens(batch, &t, 1, pos++, true);
        if (llama_process(g_ctx, LLAMA_PROCESS_TYPE_DECODE, batch) != 0) break;
    }
    salida += pendiente;
    llama_sampler_free(smpl);
    llama_batch_ext_free(batch);
    return a_bytes(env, salida);
}

extern "C" JNIEXPORT void JNICALL
Java_ec_aiess_aiess_LlmBridge_detener(JNIEnv *, jobject) { g_stop = true; }

extern "C" JNIEXPORT void JNICALL
Java_ec_aiess_aiess_LlmBridge_liberar(JNIEnv *, jobject) {
    g_stop = true;
    std::lock_guard<std::mutex> lock(g_mutex);
    liberar_locked();
}

extern "C" JNIEXPORT jboolean JNICALL
Java_ec_aiess_aiess_LlmBridge_cargado(JNIEnv *, jobject) { return g_ctx != nullptr ? JNI_TRUE : JNI_FALSE; }
