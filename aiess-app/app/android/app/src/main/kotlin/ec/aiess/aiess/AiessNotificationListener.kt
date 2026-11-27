package ec.aiess.aiess

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.provider.Settings
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

/** Lee notificaciones de correo y abre el pop-up del robot guardián de AIESS. */
class AiessNotificationListener : NotificationListenerService() {

    companion object {
        const val PREFS = "aiess_nativo"
        const val CANAL = "aiess_alertas"
        const val TAG = "AiessGuardian"
        // Por ahora solo correo. (SMS/WhatsApp: agregar aqui sus paquetes cuando se quiera.)
        val APPS = mapOf(
            "com.google.android.gm" to "Gmail",
            "com.google.android.gm.lite" to "Gmail Go",
            "com.microsoft.office.outlook" to "Outlook",
            "com.samsung.android.email.provider" to "Correo Samsung",
            "com.yahoo.mobile.client.android.mail" to "Yahoo Mail",
            "ch.protonmail.android" to "Proton Mail",
            "com.readdle.spark" to "Spark",
            "me.bluemail.mail" to "BlueMail",
            "org.kman.AquaMail" to "Aqua Mail",
            "com.fsck.k9" to "K-9 Mail",
            "net.thunderbird.android" to "Thunderbird",
            "com.easilydo.mail" to "Edison Mail",
            "com.android.email" to "Correo",
            "com.google.android.email" to "Correo",
            "com.transsion.email" to "Correo",
            "com.huawei.email" to "Correo Huawei",
            "com.yandex.mail" to "Yandex Mail",
            "com.zoho.mail" to "Zoho Mail",
        )
        private val vistos = ArrayDeque<Int>()
        /** true mientras Android tiene conectado el lector (si no, nunca llegan los correos). */
        @Volatile var conectado = false

        fun guardianActivo(ctx: Context) = ctx.getSharedPreferences(PREFS, MODE_PRIVATE).getBoolean("activo", true)
        fun umbral(ctx: Context) = ctx.getSharedPreferences(PREFS, MODE_PRIVATE).getInt("umbral", 0)

        fun abrirAlerta(ctx: Context, app: String, titulo: String, texto: String, paquete: String) {
            val intent = Intent(ctx, AlertaActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                putExtra("app", app); putExtra("titulo", titulo); putExtra("texto", texto); putExtra("paquete", paquete)
            }
            if (!Settings.canDrawOverlays(ctx)) {
                Log.i(TAG, "sin permiso de superposicion: aviso por notificacion")
                notificar(ctx, intent, titulo)
                return
            }
            val km = ctx.getSystemService(android.app.KeyguardManager::class.java)
            val pm = ctx.getSystemService(android.os.PowerManager::class.java)
            if (km.isKeyguardLocked || !pm.isInteractive) {
                // Bloqueado o pantalla apagada: una ventana flotante no se ve sobre el bloqueo.
                // Como una llamada entrante: aviso a pantalla completa que enciende la pantalla.
                Log.i(TAG, "telefono bloqueado: aviso a pantalla completa ($app)")
                avisoPantallaCompleta(ctx, intent, app, titulo)
            } else {
                // Desbloqueado: ventana flotante del sistema encima de cualquier app (como Truecaller).
                OverlayAlerta.mostrar(ctx, mapOf("app" to app, "titulo" to titulo, "texto" to texto))
            }
        }

        /** Aviso urgente que enciende la pantalla y abre el robot sobre el bloqueo. */
        private fun avisoPantallaCompleta(ctx: Context, intent: Intent, app: String, titulo: String) {
            val nm = ctx.getSystemService(NotificationManager::class.java)
            val canal = "aiess_urgente"
            if (Build.VERSION.SDK_INT >= 26) {
                nm.createNotificationChannel(NotificationChannel(canal, "Correos sospechosos (urgente)", NotificationManager.IMPORTANCE_HIGH).apply {
                    lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                })
            }
            val pi = PendingIntent.getActivity(ctx, (app + titulo).hashCode(), intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            val n = Notification.Builder(ctx, canal)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("AIESS revisó un correo de $app")
                .setContentText(if (titulo.isBlank()) "Toca para ver si es seguro" else "De: $titulo · toca para ver si es seguro")
                .setCategory(Notification.CATEGORY_CALL)
                .setVisibility(Notification.VISIBILITY_PUBLIC)
                .setFullScreenIntent(pi, true)
                .setContentIntent(pi)
                .setAutoCancel(true)
                .build()
            nm.notify(7311, n)
        }

        /** Sin permiso de superposicion: aviso propio que abre el pop-up al tocarlo. */
        private fun notificar(ctx: Context, intent: Intent, titulo: String) {
            val nm = ctx.getSystemService(NotificationManager::class.java)
            if (Build.VERSION.SDK_INT >= 26) {
                nm.createNotificationChannel(NotificationChannel(CANAL, "Alertas de AIESS", NotificationManager.IMPORTANCE_HIGH))
            }
            val pi = PendingIntent.getActivity(ctx, titulo.hashCode(), intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            val n = Notification.Builder(ctx, CANAL)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("AIESS revisó un mensaje")
                .setContentText("Toca para ver si \"$titulo\" es seguro")
                .setContentIntent(pi).setAutoCancel(true).build()
            nm.notify(titulo.hashCode(), n)
        }
    }

    override fun onListenerConnected() {
        conectado = true
        Log.i(TAG, "guardian conectado")
    }

    override fun onListenerDisconnected() {
        conectado = false
        Log.w(TAG, "guardian desconectado: pidiendo reconexion")
        requestRebind(android.content.ComponentName(this, AiessNotificationListener::class.java))
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        // Diagnóstico: registra TODO aviso que llega, antes de cualquier filtro.
        Log.i(TAG, "aviso recibido de ${sbn.packageName} (resumen=${sbn.notification.flags and Notification.FLAG_GROUP_SUMMARY != 0})")
        val app = APPS[sbn.packageName] ?: return
        if (!guardianActivo(this)) { Log.i(TAG, "descartado: guardian apagado"); return }
        val n = sbn.notification
        if (n.flags and Notification.FLAG_GROUP_SUMMARY != 0) return
        if (n.flags and Notification.FLAG_ONGOING_EVENT != 0) return
        val e = n.extras
        val titulo = e.getCharSequence(Notification.EXTRA_TITLE)?.toString().orEmpty()
        val texto = (e.getCharSequence(Notification.EXTRA_BIG_TEXT) ?: e.getCharSequence(Notification.EXTRA_TEXT))
            ?.toString().orEmpty()
        if (texto.isBlank()) return

        val firma = (sbn.key + sbn.postTime + texto).hashCode()
        synchronized(vistos) {
            if (firma in vistos) return
            vistos.addLast(firma)
            if (vistos.size > 60) vistos.removeFirst()
        }
        val p = PreFiltro.puntaje(titulo, texto)
        Log.i(TAG, "correo de $app: puntaje $p (umbral ${umbral(this)})")
        if (p < umbral(this)) return
        abrirAlerta(this, app, titulo, texto, sbn.packageName)
    }
}
