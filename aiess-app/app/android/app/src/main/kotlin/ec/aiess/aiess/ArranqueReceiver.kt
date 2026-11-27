package ec.aiess.aiess

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Al encender el teléfono (o actualizar la app) vuelve a activar el guardián, sin abrir AIESS. */
class ArranqueReceiver : BroadcastReceiver() {
    override fun onReceive(ctx: Context, intent: Intent) {
        if (AiessNotificationListener.guardianActivo(ctx)) ServicioAviso.iniciar(ctx)
    }
}
