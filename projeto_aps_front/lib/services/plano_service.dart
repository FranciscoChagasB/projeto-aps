import 'package:dio/dio.dart';
import '../models/plano.dart';
import 'api_client.dart';

class PlanoService {
  final Dio _dio = ApiClient().dio;

  Future<List<Plano>> getPlanosByCrianca(int criancaId) async {
    try {
      final response = await _dio.get('/planos/crianca/$criancaId');
      return (response.data as List).map((json) => Plano.fromJson(json)).toList();
    } on DioException {
      throw Exception('Falha ao buscar os planos da criança.');
    }
  }

  Future<Plano> createPlano(Map<String, dynamic> planoData) async {
    try {
      final response = await _dio.post('/planos', data: planoData);
      return Plano.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Falha ao criar plano: ${e.response?.data['message']}');
    }
  }

  Future<Plano> updatePlano(int planoId, Map<String, dynamic> planoUpdateData) async {
    try {
      final response = await _dio.put('/planos/$planoId', data: planoUpdateData);
      return Plano.fromJson(response.data);
    } on DioException {
      throw Exception('Falha ao atualizar o plano.');
    }
  }

  Future<Plano> addAtividadesAoPlano(int planoId, List<int> atividadeIds) async {
    try {
      final response = await _dio.patch('/planos/$planoId/adicionar-atividades', data: atividadeIds);
      return Plano.fromJson(response.data);
    } on DioException {
      throw Exception('Falha ao adicionar atividades ao plano.');
    }
  }
  
  Future<Plano> removeAtividadesDoPlano(int planoId, List<int> atividadeIds) async {
    try {
      final response = await _dio.patch('/planos/$planoId/remover-atividades', data: atividadeIds);
      return Plano.fromJson(response.data);
    } on DioException {
      throw Exception('Falha ao remover atividades do plano.');
    }
  }

  Future<void> deletePlano(int planoId) async {
    try {
      await _dio.delete('/planos/$planoId');
    } on DioException {
      throw Exception('Falha ao deletar o plano.');
    }
  }
}