/// Ayudas para leer el JSON del catálogo respetando `strict-casts`.
library;

/// Lista de textos. Si el campo no existe devuelve una lista vacía.
List<String> listaDeTextos(Object? valor) =>
    (valor as List<dynamic>? ?? const []).cast<String>();

/// Lista de objetos JSON. Si el campo no existe devuelve una lista vacía.
List<Map<String, dynamic>> listaDeMapas(Object? valor) =>
    (valor as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
