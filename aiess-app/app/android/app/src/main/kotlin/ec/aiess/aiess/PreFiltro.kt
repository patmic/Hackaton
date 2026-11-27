package ec.aiess.aiess

import java.text.Normalizer

/**
 * Triaje nativo de cada notificacion (microsegundos, sin cargar Flutter ni el modelo).
 * Solo decide si vale la pena abrir el pop-up; el analisis real lo hace Dart (OSINT + LFM2).
 */
object PreFiltro {
    private val URL = Regex("""(https?://|www\.)\S+|\b[a-z0-9-]+\.(com|net|org|xyz|top|site|info|online|ly|io|link|click|ec|gob\.ec)(/\S*)?\b""")
    private val ACORTADORES = listOf("bit.ly", "cutt.ly", "shorturl.at", "rebrand.ly", "t.ly", "is.gd", "tinyurl", "ow.ly", "rb.gy", "s.id", "goo.gl")
    private val CONTEXTO = Regex("""\b(iess|biess|afiliad\w*|afiliacion\w*|instituto ecuatoriano|jubilad\w*|pension\w*|sri|registro civil|cesantia|fondos de reserva|turno medico|aportes?)\b""")
    private val FUERTES = Regex(
        """\b(clave|contrasena|codigo de (verificacion|seguridad)|tarjeta|cvv|cedula|selfie|fecha de nacimiento|""" +
        """pago|pague|transfer\w*|deposit\w*|tasa|bono|reembolso|premio|ganador|devolucion|suspend\w*|bloque\w*|""" +
        """multa|embargo|urgente|hoy mismo|inmediat\w*|ultimo aviso|qr|escane\w*|apk|instal\w*|verifi\w*|actualiz\w*)\b"""
    )

    /** ¿El ASUNTO habla del IESS? Solo entonces el guardián avisa (misma regla que asuntoDelIess en Dart). */
    private val ASUNTO_IESS = Regex(
        """\b(iess|i\.e\.s\.s|biess|seguro social|seguridad social|afiliad\w*|afiliacion\w*|instituto ecuatoriano|jubilad\w*|jubilacion\w*|pension\w*|""" +
        """montepio|cesantia\w*|fondos? de reserva|aportes?|planillas?|prestamos? (quirografario|hipotecario)\w*|""" +
        """decimo (tercero|cuarto)|turno medico|cita medica)\b"""
    )

    fun asuntoDelIess(asunto: String): Boolean = ASUNTO_IESS.containsMatchIn(plegar(asunto))

    fun plegar(s: String): String =
        Normalizer.normalize(s, Normalizer.Form.NFD).replace(Regex("\\p{Mn}+"), "").lowercase()

    /** Puntaje 0..10. Umbral recomendado: 3. */
    fun puntaje(titulo: String, texto: String): Int {
        val t = plegar("$titulo\n$texto")
        var p = 0
        if (URL.containsMatchIn(t)) p += 1
        if (ACORTADORES.any { t.contains(it) }) p += 3
        if (CONTEXTO.containsMatchIn(t)) p += 1
        p += FUERTES.findAll(t).map { it.value }.distinct().take(3).count() * 2
        return p.coerceAtMost(10)
    }
}
