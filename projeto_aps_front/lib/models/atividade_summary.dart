class AtividadeSummary {
  final int id;
  final String titulo;

  AtividadeSummary({
    required this.id,
    required this.titulo,
  });

  factory AtividadeSummary.fromJson(Map<String, dynamic> json) {
    return AtividadeSummary(
      id: json['id'],
      titulo: json['titulo'],
    );
  }
}