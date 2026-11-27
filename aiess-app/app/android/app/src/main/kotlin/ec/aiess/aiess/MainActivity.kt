package ec.aiess.aiess

import android.content.Intent
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private var canal: MethodChannel? = null
    private var compartido: Map<String, String?>? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val m = flutterEngine.dartExecutor.binaryMessenger
        LlmBridge.registrar(m)
        Plataforma.registrar(this, m)
        Plataforma.reconectar(this) // el guardián vuelve a escuchar aunque Android lo haya soltado
        if (AiessNotificationListener.guardianActivo(this)) ServicioAviso.iniciar(this) // evita que Android congele la app
        compartido = leerCompartido(intent)
        canal = MethodChannel(m, "aiess/compartir").also {
            it.setMethodCallHandler { call, result ->
                if (call.method == "inicial") { result.success(compartido); compartido = null } else result.notImplemented()
            }
        }
    }

    /** Texto o captura de pantalla compartidos con "Revisar con la pantera". */
    private fun leerCompartido(i: Intent?): Map<String, String?>? {
        if (i?.action != Intent.ACTION_SEND) return null
        val tipo = i.type ?: return null
        if (tipo.startsWith("text/")) return mapOf("texto" to i.getStringExtra(Intent.EXTRA_TEXT))
        if (tipo.startsWith("image/")) {
            val uri: Uri? = if (Build.VERSION.SDK_INT >= 33) i.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
            else @Suppress("DEPRECATION") i.getParcelableExtra(Intent.EXTRA_STREAM)
            val ruta = uri?.let { copiar(it) } ?: return null
            return mapOf("imagen" to ruta, "texto" to i.getStringExtra(Intent.EXTRA_TEXT))
        }
        return null
    }

    /** Copia la imagen a la caché privada de la app (ML Kit lee desde un archivo local). */
    private fun copiar(uri: Uri): String? = try {
        val destino = File(cacheDir, "captura_${System.currentTimeMillis()}.img")
        contentResolver.openInputStream(uri)?.use { entrada -> destino.outputStream().use { entrada.copyTo(it) } }
        destino.absolutePath
    } catch (e: Exception) {
        null
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        leerCompartido(intent)?.let { canal?.invokeMethod("compartido", it) }
    }
}
