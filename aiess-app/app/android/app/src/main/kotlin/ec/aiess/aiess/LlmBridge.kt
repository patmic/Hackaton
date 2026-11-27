package ec.aiess.aiess

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/** JNI hacia llama.cpp (libaiess_llm.so). Estado global del proceso: un solo modelo cargado. */
object LlmBridge {
    interface TokenCallback { fun onToken(bytes: ByteArray) }

    init { System.loadLibrary("aiess_llm") }

    external fun cargar(ruta: String, nCtx: Int, hilos: Int): Boolean
    external fun generar(prompt: String, prefijo: String, maxTokens: Int, temperatura: Float, cb: TokenCallback): ByteArray
    external fun detener()
    external fun liberar()
    external fun cargado(): Boolean

    private val hilo = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())
    @Volatile var rutaActual: String? = null

    /** Registra los canales en un FlutterEngine (app principal o pop-up). */
    fun registrar(messenger: BinaryMessenger) {
        var sink: EventChannel.EventSink? = null
        EventChannel(messenger, "aiess/llm/tokens").setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, events: EventChannel.EventSink?) { sink = events }
            override fun onCancel(args: Any?) { sink = null }
        })
        MethodChannel(messenger, "aiess/llm").setMethodCallHandler { call, result ->
            when (call.method) {
                "cargar" -> {
                    val ruta = call.argument<String>("ruta")!!
                    val nCtx = call.argument<Int>("nCtx") ?: 2048
                    val hilos = call.argument<Int>("hilos") ?: Runtime.getRuntime().availableProcessors().coerceIn(2, 4)
                    hilo.execute {
                        val ok = if (cargado() && rutaActual == ruta) true else cargar(ruta, nCtx, hilos)
                        if (ok) rutaActual = ruta
                        main.post { result.success(ok) }
                    }
                }
                "generar" -> {
                    val prompt = call.argument<String>("prompt")!!
                    val prefijo = call.argument<String>("prefijo") ?: ""
                    val maxTokens = call.argument<Int>("maxTokens") ?: 400
                    val temp = (call.argument<Double>("temperatura") ?: 0.0).toFloat()
                    hilo.execute {
                        val out = generar(prompt, prefijo, maxTokens, temp, object : TokenCallback {
                            override fun onToken(bytes: ByteArray) {
                                val s = String(bytes, Charsets.UTF_8)
                                main.post { sink?.success(s) }
                            }
                        })
                        main.post { result.success(String(out, Charsets.UTF_8)) }
                    }
                }
                "detener" -> { detener(); result.success(null) }
                "liberar" -> { hilo.execute { liberar(); rutaActual = null; main.post { result.success(null) } } }
                "cargado" -> result.success(cargado())
                else -> result.notImplemented()
            }
        }
    }
}
