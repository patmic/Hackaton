import 'package:aiess/features/analisis/motor.dart';
import 'package:flutter_test/flutter_test.dart';

// Texto como lo devuelve el OCR del diagrama de arquitectura del usuario.
const diagrama = '''ZONA INTERNA IESS (Intercepción, Doble Fase de Seguridad, Firma Digital y Auditoría)
Funcionario IESS (Servidor Correo Interno) Envía correo dirigido al ciudadano
Proxy SMTP Interceptor (Corta el envío antes de salir a Internet)
Fase 1: Valida remitente en Whitelist Fase 2: Revisa topología limpia (anti-phishing)
Hash 1: Identidad del remitente Hash 2: Contenido completo del correo Inyecta: Hash 2 + Botón "Verificar en App"
CORREO BLOQUEADO (550) Falla Fase 1 (Whitelist) o Fase 2 (Topología/Phishing)
API REST de Verificación (FastAPI - HTTP / JSON) GET /verificar/{hash_2} GET /logs (Auditoría)
Base de Datos IESS (SQLite / PostgreSQL) ALERTA DE PHISHING Hash inexistente o correo alterado. IA explica señales de alerta.''';

void main() {
  test('el diagrama de arquitectura NO es un correo', () {
    expect(pareceCorreoOMensaje(diagrama), isFalse);
    expect(motivoNoEsMensaje(diagrama), contains('diagrama'));
  });
  test('una captura de correo con encabezados sí lo es', () {
    expect(pareceCorreoOMensaje('De: notificaciones@iess-pagos.example\nPara: luis@correo.ec\nAsunto: Su afiliación será suspendida\nEstimado afiliado, actualice su clave hoy.'), isTrue);
  });
  test('un correo sin encabezados pero con saludo y despedida sí lo es', () {
    expect(pareceCorreoOMensaje('Estimado afiliado:\nSu reembolso está listo. Ingrese a https://iess-pagos.example para cobrarlo.\nAtentamente, Departamento de Afiliación'), isTrue);
  });
  test('un SMS corto con enlace sí lo es', () {
    expect(pareceCorreoOMensaje('IESS: su pension sera suspendida hoy. Ingrese a https://iess-pagos.example'), isTrue);
  });
  test('texto de una foto cualquiera no lo es', () {
    expect(pareceCorreoOMensaje('Feliz cumpleaños mamá te queremos mucho, que Dios te bendiga siempre'), isFalse);
  });
  test('imagen sin texto no lo es', () {
    expect(pareceCorreoOMensaje('  '), isFalse);
  });
}
