package ec.aiess.aiess

import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Gravity
import android.view.WindowManager
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterSurfaceView
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * Pop-up tipo Truecaller: ventana flotante del sistema (TYPE_APPLICATION_OVERLAY) que dibuja la UI Flutter
 * (entrada Dart `alertaMain`) ENCIMA de la app donde llegó el correo, sin abrir AIESS ni cambiar de tarea.
 * La ventana mide lo mismo que la tarjeta (Dart informa su alto), así el resto de la pantalla sigue usable.
 */
object OverlayAlerta {
    private const val TAG = "AiessGuardian"
    private val main = Handler(Looper.getMainLooper())
    private var engine: FlutterEngine? = null
    private var vista: FlutterView? = null
    private var canal: MethodChannel? = null
    private var params: WindowManager.LayoutParams? = null
    private var payload: Map<String, String> = emptyMap()

    fun mostrar(ctx: Context, datos: Map<String, String>) {
        val app = ctx.applicationContext
        main.post {
            payload = datos
            // Siempre una ventana NUEVA por correo: si quedó una anterior (aunque ya no se vea), se destruye.
            if (vista != null || engine != null) {
                Log.i(TAG, "cerrando pop-up anterior antes de mostrar el nuevo")
                destruirAhora(app)
            }
            try {
                crear(app)
                Log.i(TAG, "pop-up flotante mostrado (${datos["app"]})")
            } catch (e: Exception) {
                Log.e(TAG, "no se pudo crear el pop-up flotante", e)
                cerrar(app)
            }
        }
    }

    private fun crear(app: Context) {
        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(app)
        loader.ensureInitializationComplete(app, null)
        val eng = FlutterEngine(app)
        eng.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint(loader.findAppBundlePath(), "alertaMain"))
        LlmBridge.registrar(eng.dartExecutor.binaryMessenger)

        val ch = MethodChannel(eng.dartExecutor.binaryMessenger, "aiess/alerta")
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                "payload" -> result.success(payload)
                "tamano" -> {
                    val dp = (call.argument<Double>("alto") ?: 360.0)
                    redimensionar(app, dp)
                    result.success(null)
                }
                "cerrar" -> { result.success(null); cerrar(app) }
                "abrirApp" -> {
                    app.startActivity(Intent(app, MainActivity::class.java).apply {
                        action = Intent.ACTION_SEND; type = "text/plain"
                        putExtra(Intent.EXTRA_TEXT, call.argument<String>("texto") ?: "")
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    })
                    result.success(null)
                    cerrar(app)
                }
                else -> result.notImplemented()
            }
        }

        val fv = FlutterView(app, FlutterSurfaceView(app, true)) // superficie transparente
        fv.attachToFlutterEngine(eng)
        val dm = app.resources.displayMetrics
        val idBarra = app.resources.getIdentifier("status_bar_height", "dimen", "android")
        val barra = if (idBarra > 0) app.resources.getDimensionPixelSize(idBarra) else (24 * dm.density).toInt()
        val lp = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            (420 * dm.density).toInt(),
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP
            y = barra + (8 * dm.density).toInt()
        }
        app.getSystemService(WindowManager::class.java).addView(fv, lp)
        // Con la ventana flotante ya visible, Android permite arrancar el servicio en primer plano
        // que evita que el proceso se congele mientras se dibuja el aviso.
        ServicioAviso.iniciar(app)
        eng.lifecycleChannel.appIsResumed()
        engine = eng; vista = fv; canal = ch; params = lp
    }

    private fun redimensionar(app: Context, altoDp: Double) {
        val fv = vista ?: return
        val lp = params ?: return
        val px = (altoDp.coerceIn(140.0, 600.0) * app.resources.displayMetrics.density).toInt()
        if (lp.height == px) return
        lp.height = px
        try { app.getSystemService(WindowManager::class.java).updateViewLayout(fv, lp) } catch (_: Exception) {}
    }

    fun cerrar(app: Context) {
        main.post { destruirAhora(app) }
    }

    private fun destruirAhora(app: Context) {
        vista?.let {
            try { app.getSystemService(WindowManager::class.java).removeViewImmediate(it) } catch (_: Exception) {}
            try { it.detachFromFlutterEngine() } catch (_: Exception) {}
        }
        try { engine?.destroy() } catch (_: Exception) {}
        engine = null; vista = null; canal = null; params = null
    }
}
