import 'package:dio/dio.dart';
import '../models/crianca.dart';
import 'api_client.dart';

class CriancaService {
  final Dio _dio = ApiClient().dio;

  /// Busca a lista de crianças do responsável logado.
  Future<List<Crianca>> getMinhasCriancas() async {
    try {
      final response = await _dio.get('/criancas/meus');
      return (response.data as List)
          .map((json) => Crianca.fromJson(json))
          .toList();
    } on DioException {
      throw Exception('Falha ao buscar suas crianças.');
    }
  }

  /// Busca a lista de crianças que um terapeuta acompanha.
  Future<List<Crianca>> getCriancasDoTerapeuta() async {
    try {
      final response = await _dio.get('/criancas/terapeuta');
      return (response.data as List)
          .map((json) => Crianca.fromJson(json))
          .toList();
    } on DioException {
      throw Exception('Falha ao buscar a lista de pacientes.');
    }
  }

  /// Cria um novo registro de criança.
  Future<Crianca> createCrianca(Map<String, dynamic> criancaData) async {
    try {
      final response = await _dio.post('/criancas', data: criancaData);
      return Crianca.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          'Falha ao cadastrar criança: ${e.response?.data['message']}');
    }
  }

  /// Vincula um terapeuta a uma criança usando o código do profissional.
  Future<Crianca> vincularTerapeuta(
      int criancaId, String professionalCode) async {
    try {
      final response = await _dio.post(
        '/criancas/$criancaId/vincular-terapeuta',
        data: {'professionalCode': professionalCode},
      );
      return Crianca.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ??
          'Código inválido ou falha na operação.';
      throw Exception(errorMessage);
    }
  }

  Future<Crianca> updateCrianca(
      int id, Map<String, dynamic> criancaData) async {
    try {
      final response = await _dio.put('/criancas/$id', data: criancaData);
      return Crianca.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          'Falha ao atualizar dados da criança: ${e.response?.data['message']}');
    }
  }

  Future<void> deleteCrianca(int criancaId) async {
    try {
      await _dio.delete('/criancas/$criancaId');
    } on DioException catch (e) {
      throw Exception(
          'Falha ao atualizar dados da criança: ${e.response?.data['message']}');
    }
  }
}
