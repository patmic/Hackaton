package ec.aiess.aiess

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log

/**
 * Servicio PERMANENTE en primer plano (como "Truecaller está activo"). Mientras exista, Android/XOS
 * no congela el proceso de AIESS, así el aviso de un correo sospechoso sale al instante encima de
 * cualquier app. Arranca al abrir AIESS y al encender el teléfono.
 */
class ServicioAviso : Service() {
    companion object {
        private const val CANAL = "aiess_guardian_activo"
        private const val ID = 4417

        fun iniciar(ctx: Context) {
            try {
                val i = Intent(ctx, ServicioAviso::class.java)
                if (Build.VERSION.SDK_INT >= 26) ctx.startForegroundService(i) else ctx.startService(i)
            } catch (e: Exception) {
                Log.w("AiessGuardian", "no se pudo iniciar el servicio en primer plano", e)
            }
        }

        fun detener(ctx: Context) {
            try { ctx.stopService(Intent(ctx, ServicioAviso::class.java)) } catch (_: Exception) {}
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private val main = android.os.Handler(android.os.Looper.getMainLooper())
    private val revision = object : Runnable {
        override fun run() {
            try { Plataforma.reconectar(this@ServicioAviso) } catch (_: Exception) {}
            main.postDelayed(this, 120_000)
        }
    }

    private fun vigilar() {
        main.removeCallbacks(revision)
        main.postDelayed(revision, 3_000)
    }

    override fun onDestroy() {
        main.removeCallbacks(revision)
        super.onDestroy()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val nm = getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= 26) {
            nm.createNotificationChannel(NotificationChannel(CANAL, "Guardián AIESS activo", NotificationManager.IMPORTANCE_MIN))
        }
        val n = Notification.Builder(this, CANAL)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("AIESS te protege")
            .setContentText("Reviso tus correos para avisarte si son una estafa")
            .setOngoing(true)
            .build()
        if (Build.VERSION.SDK_INT >= 34) {
            startForeground(ID, n, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(ID, n)
        }
        Log.i("AiessGuardian", "servicio en primer plano activo")
        // Cada 2 minutos comprueba que el lector siga conectado (XOS lo suelta a veces).
        vigilar()
        return START_STICKY
    }
}
