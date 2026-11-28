package ec.aiess.aiess

import android.app.Activity
import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import java.io.File
import java.io.FileOutputStream
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.PowerManager
import android.provider.Settings
import android.service.notification.NotificationListenerService
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/** Permisos y ajustes del guardian (canal "aiess/plataforma"). */
object Plataforma {
    fun listenerActivo(ctx: Context): Boolean {
        val habilitados = Settings.Secure.getString(ctx.contentResolver, "enabled_notification_listeners") ?: return false
        val yo = ComponentName(ctx, AiessNotificationListener::class.java).flattenToString()
        return habilitados.split(":").any { it.equals(yo, ignoreCase = true) }
    }

    fun sinLimiteBateria(ctx: Context): Boolean =
        ctx.getSystemService(PowerManager::class.java).isIgnoringBatteryOptimizations(ctx.packageName)

    /** Pide a Android volver a conectar el lector de notificaciones (se suelta al reinstalar o al dormir la app). */
    fun reconectar(ctx: Context) {
        if (!listenerActivo(ctx) || AiessNotificationListener.conectado) return
        val c = ComponentName(ctx, AiessNotificationListener::class.java)
        // Algunos sistemas (XOS/Infinix) no vuelven a conectar el lector tras actualizar la app:
        // apagar y prender el componente obliga a Android a conectarlo de nuevo.
        val pm = ctx.packageManager
        pm.setComponentEnabledSetting(c, PackageManager.COMPONENT_ENABLED_STATE_DISABLED, PackageManager.DONT_KILL_APP)
        pm.setComponentEnabledSetting(c, PackageManager.COMPONENT_ENABLED_STATE_ENABLED, PackageManager.DONT_KILL_APP)
        NotificationListenerService.requestRebind(c)
        android.util.Log.i("AiessGuardian", "reconectando el lector de notificaciones")
    }

    /**
     * Infinix / Tecno / Itel (XOS, HiOS) hibernan las apps que no están en "Inicio automático" de Phone Master,
     * aunque tengan permisos de Android: sin esto los avisos de correo llegan tarde. Otras marcas: null.
     */
    fun intentInicioAutomatico(ctx: Context): Intent? {
        val candidatos = listOf(
            ComponentName("com.transsion.phonemaster", "com.cyin.himgr.autostart.AutoStartActivity"),
            ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"),
            ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity"),
            ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"),
            ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"),
        )
        for (c in candidatos) {
            val i = Intent().setComponent(c).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            if (ctx.packageManager.resolveActivity(i, 0) != null) return i
        }
        return null
    }

    fun registrar(act: Activity, messenger: BinaryMessenger) {
        val prefs = act.getSharedPreferences(AiessNotificationListener.PREFS, Context.MODE_PRIVATE)
        MethodChannel(messenger, "aiess/plataforma").setMethodCallHandler { call, result ->
            when (call.method) {
                "permisos" -> result.success(mapOf(
                    "notificaciones" to listenerActivo(act),
                    "superposicion" to Settings.canDrawOverlays(act),
                    "activo" to AiessNotificationListener.guardianActivo(act),
                    "bateria" to sinLimiteBateria(act),
                    "pantallaCompleta" to (android.os.Build.VERSION.SDK_INT < 34 ||
                        act.getSystemService(android.app.NotificationManager::class.java).canUseFullScreenIntent()),
                    // No hay API para leer este ajuste del fabricante: se considera hecho tras abrirlo una vez.
                    "ahorroFabricante" to (intentInicioAutomatico(act) == null ||
                        act.getSharedPreferences(AiessNotificationListener.PREFS, Context.MODE_PRIVATE).getBoolean("ahorro_visto", false)),
                    "autoinicio" to (intentInicioAutomatico(act) == null ||
                        act.getSharedPreferences(AiessNotificationListener.PREFS, Context.MODE_PRIVATE).getBoolean("autoinicio_visto", false)),
                ))
                "abrirAjustesNotificaciones" -> {
                    act.startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)); result.success(null)
                }
                "abrirAjustesSuperposicion" -> {
                    act.startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:${act.packageName}")))
                    result.success(null)
                }
                "abrirAjustesBateria" -> {
                    // Diálogo oficial de Android: "¿Permitir que AIESS se ejecute siempre en segundo plano?"
                    try {
                        act.startActivity(Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS, Uri.parse("package:${act.packageName}")))
                    } catch (e: Exception) {
                        act.startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:${act.packageName}")))
                    }
                    result.success(null)
                }
                "reconectar" -> { reconectar(act); result.success(null) }
                "abrirAjustesPantallaCompleta" -> {
                    try {
                        act.startActivity(Intent("android.settings.MANAGE_APP_USE_FULL_SCREEN_INTENT", Uri.parse("package:${act.packageName}")))
                    } catch (e: Exception) {
                        act.startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:${act.packageName}")))
                    }
                    result.success(null)
                }
                "tieneInicioAutomatico" -> result.success(intentInicioAutomatico(act) != null)
                "abrirAhorroFabricante" -> {
                    // XOS/HiOS: Ajustes › Batería › (app) › "Sin restricciones" evita que el congelador (Hiber) la duerma.
                    try { act.startActivity(Intent(Intent.ACTION_POWER_USAGE_SUMMARY)) } catch (e: Exception) {
                        act.startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:${act.packageName}")))
                    }
                    act.getSharedPreferences(AiessNotificationListener.PREFS, Context.MODE_PRIVATE).edit().putBoolean("ahorro_visto", true).apply()
                    result.success(null)
                }
                "abrirInicioAutomatico" -> {
                    val i = intentInicioAutomatico(act)
                        ?: Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:${act.packageName}"))
                    try { act.startActivity(i) } catch (e: Exception) {
                        act.startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:${act.packageName}")))
                    }
                    act.getSharedPreferences(AiessNotificationListener.PREFS, Context.MODE_PRIVATE).edit().putBoolean("autoinicio_visto", true).apply()
                    result.success(null)
                }
                "activar" -> {
                    prefs.edit().putBoolean("activo", call.argument<Boolean>("valor") ?: true).apply(); result.success(null)
                }
                "probarAlerta" -> {
                    AiessNotificationListener.abrirAlerta(act, "Gmail", "IESS Notificaciones",
                        "Suspensión de su afiliación\nEstimado afiliado: su afiliación será suspendida hoy. Actualice sus datos y su clave en https://iess-afiliados.example/verificar",
                        "demo")
                    result.success(null)
                }
                // Portapapeles en HTML: al copiar un correo en Gmail o Yahoo, el enlace de la IMAGEN del sello
                // solo viaja en la versión HTML (el texto plano lo pierde). Se devuelve para leer sus enlaces.
                "portapapelesHtml" -> {
                    val cm = act.getSystemService(Context.CLIPBOARD_SERVICE) as android.content.ClipboardManager
                    val clip = cm.primaryClip
                    val html = if (clip != null && clip.itemCount > 0) clip.getItemAt(0).htmlText else null
                    result.success(html)
                }
                // PDF en el celular: cada página se dibuja como imagen (PdfRenderer de Android, sin abrir enlaces
                // ni ejecutar nada del PDF) y luego el OCR de ML Kit la lee en el equipo. Máximo 5 páginas.
                "pdfAImagenes" -> {
                    val ruta = call.argument<String>("ruta")
                    if (ruta == null) { result.success(emptyList<String>()); return@setMethodCallHandler }
                    Thread {
                        val salida = mutableListOf<String>()
                        try {
                            ParcelFileDescriptor.open(File(ruta), ParcelFileDescriptor.MODE_READ_ONLY).use { fd ->
                                PdfRenderer(fd).use { pdf ->
                                    for (i in 0 until minOf(pdf.pageCount, 5)) {
                                        pdf.openPage(i).use { pag ->
                                            val bmp = Bitmap.createBitmap(pag.width * 2, pag.height * 2, Bitmap.Config.ARGB_8888)
                                            bmp.eraseColor(Color.WHITE)
                                            pag.render(bmp, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                                            val f = File(act.cacheDir, "aiess_pdf_$i.png")
                                            FileOutputStream(f).use { bmp.compress(Bitmap.CompressFormat.PNG, 100, it) }
                                            bmp.recycle()
                                            salida.add(f.absolutePath)
                                        }
                                    }
                                }
                            }
                        } catch (_: Exception) {}
                        act.runOnUiThread { result.success(salida) }
                    }.start()
                }
                else -> result.notImplemented()
            }
        }
    }
}
