import 'package:dio/dio.dart';
import '../models/user_admin.dart';
import 'api_client.dart';

class AdminService {
  final Dio _dio = ApiClient().dio;

  Future<List<UserAdmin>> getAllUsers() async {
    try {
      final response = await _dio.get('/admin/users');
      return (response.data as List).map((json) => UserAdmin.fromJson(json)).toList();
    } on DioException {
      throw Exception('Falha ao buscar a lista de usuários.');
    }
  }

  Future<UserAdmin> updateUserStatus(int userId, bool isActive) async {
    try {
      final response = await _dio.patch(
        '/admin/users/$userId/status',
        data: {'active': isActive},
      );
      return UserAdmin.fromJson(response.data);
    } on DioException {
      throw Exception('Falha ao atualizar o status do usuário.');
    }
  }
}