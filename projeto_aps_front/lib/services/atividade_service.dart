import 'package:dio/dio.dart';
import '../models/atividade.dart';
import 'api_client.dart';

class AtividadeService {
  final Dio _dio = ApiClient().dio;

  Future<List<Atividade>> getAllAtividades() async {
    try {
      final response = await _dio.get('/atividades');
      return (response.data as List).map((json) => Atividade.fromJson(json)).toList();
    } on DioException {
      throw Exception('Falha ao buscar a lista de atividades.');
    }
  }

  Future<Atividade> createAtividade(Map<String, dynamic> atividadeData) async {
    try {
      final response = await _dio.post('/atividades', data: atividadeData);
      return Atividade.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Falha ao criar atividade: ${e.response?.data['message']}');
    }
  }

  Future<Atividade> updateAtividade(int id, Map<String, dynamic> atividadeData) async {
    try {
      final response = await _dio.put('/atividades/$id', data: atividadeData);
      return Atividade.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Falha ao atualizar atividade: ${e.response?.data['message']}');
    }
  }

  Future<void> deleteAtividade(int id) async {
    try {
      await _dio.delete('/atividades/$id');
    } on DioException {
      throw Exception('Falha ao deletar atividade.');
    }
  }
}