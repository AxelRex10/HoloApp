// Debe ser una función de nivel superior (top-level) para poder
// ejecutarse en un isolate separado con compute().
List<Map<String, dynamic>> calcularTopTalentos(
  List<Map<String, dynamic>> talentos,
) {
  final List<Map<String, dynamic>> lista =
      List<Map<String, dynamic>>.from(talentos);

  lista.sort((a, b) {
    final int subsA = a['subscriber_count'] as int? ?? 0;
    final int subsB = b['subscriber_count'] as int? ?? 0;
    return subsB.compareTo(subsA);
  });

  return lista.take(10).toList();
}