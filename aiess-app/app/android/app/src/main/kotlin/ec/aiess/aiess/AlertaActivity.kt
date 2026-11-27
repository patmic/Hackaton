package ec.aiess.aiess

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** Pop-up transparente que se dibuja sobre la app donde llego el mensaje. Entrada Dart: alertaMain(). */
class AlertaActivity : FlutterActivity() {
    private var canal: MethodChannel? = null

    override fun getDartEntrypointFunctionName() = "alertaMain"
    override fun getBackgroundMode() = BackgroundMode.transparent

    private fun payload(i: Intent?) = mapOf(
        "app" to (i?.getStringExtra("app") ?: ""),
        "titulo" to (i?.getStringExtra("titulo") ?: ""),
        "texto" to (i?.getStringExtra("texto") ?: ""),
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        LlmBridge.registrar(flutterEngine.dartExecutor.binaryMessenger)
        Plataforma.registrar(this, flutterEngine.dartExecutor.binaryMessenger)
        canal = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "aiess/alerta").also {
            it.setMethodCallHandler { call, result ->
                when (call.method) {
                    "payload" -> result.success(payload(intent))
                    "cerrar" -> { result.success(null); finish() }
                    "abrirApp" -> {
                        startActivity(Intent(this, MainActivity::class.java).apply {
                            action = Intent.ACTION_SEND; type = "text/plain"
                            putExtra(Intent.EXTRA_TEXT, call.argument<String>("texto") ?: "")
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        })
                        result.success(null); finish()
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        canal?.invokeMethod("nuevo", payload(intent))
    }
}
