import 'atividade_summary.dart';
import 'crianca_summary.dart';

enum StatusRegistro {
  CONCLUIDO,
  CONCLUIDO_COM_DIFICULDADE,
  NAO_CONCLUIDO,
  UNKNOWN;

  static StatusRegistro fromString(String? status) {
    switch (status) {
      case 'CONCLUIDO':
        return StatusRegistro.CONCLUIDO;
      case 'CONCLUIDO_COM_DIFICULDADE':
        return StatusRegistro.CONCLUIDO_COM_DIFICULDADE;
      case 'NAO_CONCLUIDO':
        return StatusRegistro.NAO_CONCLUIDO;
      default:
        return StatusRegistro.UNKNOWN;
    }
  }
}

class Registro {
  final int id;
  final AtividadeSummary atividade;
  final CriancaSummary crianca;
  final DateTime dataHoraConclusao;
  final String? observacoesDoResponsavel;
  final String? feedbackDoTerapeuta;
  final StatusRegistro status;

  Registro({
    required this.id,
    required this.atividade,
    required this.crianca,
    required this.dataHoraConclusao,
    this.observacoesDoResponsavel,
    this.feedbackDoTerapeuta,
    required this.status,
  });

  /// Factory constructor para criar um Registro a partir de um JSON.
  factory Registro.fromJson(Map<String, dynamic> json) {
    return Registro(
      id: json['id'],
      atividade: AtividadeSummary.fromJson(json['atividade']),
      crianca: CriancaSummary.fromJson(json['crianca']),
      dataHoraConclusao: DateTime.parse(json['dataHoraConclusao']),
      observacoesDoResponsavel: json['observacoesDoResponsavel'],
      feedbackDoTerapeuta: json['feedbackDoTerapeuta'],
      status: StatusRegistro.fromString(json['status']),
    );
  }
}