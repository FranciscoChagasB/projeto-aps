enum TipoAtividade {
  LUDICA,
  EDUCACIONAL,
  TERAPEUTICA,
  FISICA,
  UNKNOWN; // Valor padrão para casos inesperados

  static TipoAtividade fromString(String? type) {
    switch (type) {
      case 'LUDICA':
        return TipoAtividade.LUDICA;
      case 'EDUCACIONAL':
        return TipoAtividade.EDUCACIONAL;
      case 'TERAPEUTICA':
        return TipoAtividade.TERAPEUTICA;
      case 'FISICA':
        return TipoAtividade.FISICA;
      default:
        return TipoAtividade.UNKNOWN;
    }
  }
}

class Atividade {
  final int id;
  final String titulo;
  final String descricaoDetalhada;
  final int duracaoEstimadaMinutos;
  final TipoAtividade tipo;

  Atividade({
    required this.id,
    required this.titulo,
    required this.descricaoDetalhada,
    required this.duracaoEstimadaMinutos,
    required this.tipo,
  });

  /// Factory constructor para criar uma Atividade a partir de um JSON.
  factory Atividade.fromJson(Map<String, dynamic> json) {
    return Atividade(
      id: json['id'],
      titulo: json['titulo'],
      descricaoDetalhada: json['descricaoDetalhada'],
      duracaoEstimadaMinutos: json['duracaoEstimadaMinutos'],
      // Converte a String do JSON para nosso Enum
      tipo: TipoAtividade.fromString(json['tipo']),
    );
  }
}