# ML Kit: solo usamos el reconocedor latino; los otros idiomas no se incluyen.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Puente JNI con llama.cpp: los nombres deben quedar intactos (C++ los busca por nombre).
-keep class ec.aiess.aiess.LlmBridge { *; }
-keep interface ec.aiess.aiess.LlmBridge$TokenCallback { *; }
-keep class * implements ec.aiess.aiess.LlmBridge$TokenCallback { *; }
-keepclasseswithmembernames class * { native <methods>; }

# Servicio de notificaciones y pop-up (los declara el manifest).
-keep class ec.aiess.aiess.AiessNotificationListener { *; }
-keep class ec.aiess.aiess.AlertaActivity { *; }
