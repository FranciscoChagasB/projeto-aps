import 'user_summary.dart';

class Crianca {
  final int id;
  final String nomeCompleto;
  final DateTime dataNascimento;
  final String? descricaoDiagnostico;
  final String? informacoesAdicionais;
  final String? fotoCriancaBase64;
  final String? anexoDiagnosticoBase64;
  final UserSummary responsavel;
  final List<UserSummary> terapeutas;

  Crianca({
    required this.id,
    required this.nomeCompleto,
    required this.dataNascimento,
    this.descricaoDiagnostico,
    this.informacoesAdicionais,
    this.fotoCriancaBase64,
    this.anexoDiagnosticoBase64,
    required this.responsavel,
    required this.terapeutas,
  });

  factory Crianca.fromJson(Map<String, dynamic> json) {
    return Crianca(
      id: json['id'],
      nomeCompleto: json['nomeCompleto'],
      dataNascimento: DateTime.parse(json['dataNascimento']),
      descricaoDiagnostico: json['descricaoDiagnostico'],
      informacoesAdicionais: json['informacoesAdicionais'],
      fotoCriancaBase64: json['fotoCrianca'], // Mapeando do DTO
      anexoDiagnosticoBase64: json['anexoDiagnostico'], // Mapeando do DTO
      responsavel: UserSummary.fromJson(json['responsavel']),
      terapeutas: (json['terapeutas'] as List)
          .map((terapeutaJson) => UserSummary.fromJson(terapeutaJson))
          .toList(),
    );
  }
}