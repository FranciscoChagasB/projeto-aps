import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthService {
  // Pega a instância Singleton do nosso cliente Dio já configurado.
  final Dio _dio = ApiClient().dio;

  /// Tenta fazer login e retorna o token JWT em caso de sucesso.
  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post('/users/login', data: {
        'email': email,
        'password': password,
      });
      return response.data['token'];
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Falha no login. Verifique suas credenciais.';
      throw Exception(errorMessage);
    }
  }

  /// Envia os dados do novo usuário para registro.
  Future<void> register(Map<String, dynamic> userData) async {
    try {
      await _dio.post('/users', data: userData);
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? 'Falha ao criar conta. Tente novamente.';
      throw Exception(errorMessage);
    }
  }
}