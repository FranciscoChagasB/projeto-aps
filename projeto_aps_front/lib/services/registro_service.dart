import 'package:dio/dio.dart';
import '../models/registro.dart';
import 'api_client.dart';

class RegistroService {
  final Dio _dio = ApiClient().dio;

  /// Busca todos os registros de um plano específico.
  Future<List<Registro>> getRegistrosByPlano(int planoId) async {
    try {
      final response = await _dio.get('/registros/plano/$planoId');
      return (response.data as List).map((json) => Registro.fromJson(json)).toList();
    } on DioException {
      throw Exception('Falha ao buscar o histórico do plano.');
    }
  }

  /// Cria um novo registro de atividade.
  Future<Registro> createRegistro(Map<String, dynamic> registroData) async {
    try {
      final response = await _dio.post('/registros', data: registroData);
      return Registro.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Falha ao salvar registro: ${e.response?.data['message']}');
    }
  }

  /// Adiciona/atualiza o feedback de um terapeuta em um registro.
  Future<Registro> addFeedback(int registroId, String feedback) async {
    try {
      // Para enviar um texto plano, passamos diretamente no `data`.
      final response = await _dio.patch('/registros/$registroId/feedback', data: feedback);
      return Registro.fromJson(response.data);
    } on DioException {
      throw Exception('Falha ao adicionar feedback.');
    }
  }

  /// Atualiza as observações de um responsável em um registro.
  Future<Registro> updateObservacoes(int registroId, String observacoes) async {
    try {
      final response = await _dio.patch('/registros/$registroId/observacoes', data: observacoes);
      return Registro.fromJson(response.data);
    } on DioException {
      throw Exception('Falha ao atualizar observações.');
    }
  }
}