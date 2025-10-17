import 'package:dio/dio.dart';
import '../models/user_admin.dart';
import 'api_client.dart';

class AdminService {
  final Dio _dio = ApiClient().dio;

  Future<List<UserAdmin>> getAllUsers({Map<String, dynamic>? filters}) async {
    try {
      // Adiciona os filtros como query parameters na requisição GET
      final response = await _dio.get('/admin', queryParameters: filters);
      return (response.data as List).map((json) => UserAdmin.fromJson(json)).toList();
    } on DioException {
      throw Exception('Falha ao buscar a lista de usuários.');
    }
  }

  Future<UserAdmin> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('/admin', data: userData);
      return UserAdmin.fromJson(response.data);
    } on DioException {
      throw Exception('Falha ao criar usuário.');
    }
  }

  Future<UserAdmin> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      final response = await _dio.put('/admin/$userId', data: userData);
      return UserAdmin.fromJson(response.data);
    } on DioException {
      throw Exception('Falha ao atualizar usuário.');
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await _dio.delete('/admin/$userId');
    } on DioException {
      throw Exception('Falha ao deletar usuário.');
    }
  }
}