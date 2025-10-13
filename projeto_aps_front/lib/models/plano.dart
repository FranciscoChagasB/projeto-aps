import 'atividade_summary.dart';
import 'crianca_summary.dart';
import 'user_summary.dart';

class Plano {
  final int id;
  final String nome;
  final String objetivo;
  final UserSummary terapeuta;
  final CriancaSummary crianca;
  final List<AtividadeSummary> atividades;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  Plano({
    required this.id,
    required this.nome,
    required this.objetivo,
    required this.terapeuta,
    required this.crianca,
    required this.atividades,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  /// Factory constructor para criar um Plano a partir de um JSON.
  factory Plano.fromJson(Map<String, dynamic> json) {
    return Plano(
      id: json['id'],
      nome: json['nome'],
      objetivo: json['objetivo'],
      terapeuta: UserSummary.fromJson(json['terapeuta']),
      crianca: CriancaSummary.fromJson(json['crianca']),
      atividades: (json['atividades'] as List)
          .map((atividadeJson) => AtividadeSummary.fromJson(atividadeJson))
          .toList(),
      dataCriacao: DateTime.parse(json['dataCriacao']),
      dataAtualizacao: DateTime.parse(json['dataAtualizacao']),
    );
  }
}