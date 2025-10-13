class CriancaSummary {
  final int id;
  final String nomeCompleto;

  CriancaSummary({
    required this.id,
    required this.nomeCompleto,
  });

  factory CriancaSummary.fromJson(Map<String, dynamic> json) {
    return CriancaSummary(
      id: json['id'],
      nomeCompleto: json['nomeCompleto'],
    );
  }
}