package ec.aiess.aiess

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Disparador de prueba del pop-up (solo por USB: protegido con android.permission.DUMP, que apps normales no tienen).
 *   adb shell am broadcast -a ec.aiess.PROBAR -n ec.aiess.aiess/.ProbarReceiver
 */
class ProbarReceiver : BroadcastReceiver() {
    override fun onReceive(ctx: Context, intent: Intent) {
        AiessNotificationListener.abrirAlerta(
            ctx, intent.getStringExtra("app") ?: "Gmail", "IESS Notificaciones",
            intent.getStringExtra("texto")
                ?: "Suspensión de su afiliación\nEstimado afiliado: su afiliación será suspendida hoy. Actualice su clave en https://iess-pagos.example/verificar",
            "prueba"
        )
    }
}
