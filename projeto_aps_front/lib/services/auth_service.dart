import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = "http://localhost:8080/users"; // 10.0.2.2 = localhost

  // MÉTODO DE LOGIN
  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final token = body['token'] as String;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);
      return token;
    } else {
      // se o backend não mandou corpo, cria uma mensagem genérica
      String message = 'Falha ao realizar o login.';
      if (response.body.isNotEmpty) {
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map && errorBody['message'] != null) {
            message = errorBody['message'];
          }
        } catch (_) {
          // corpo não é JSON, mantém a mensagem genérica
        }
      } else if (response.statusCode == 403) {
        message = 'Credenciais inválidas ou usuário não encontrado.';
      }
      throw Exception(message);
    }
  }

  // MÉTODO DE REGISTRO
  Future<void> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl'), // Endpoint de registro
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 201) {
      // Registro bem-sucedido, não precisa retornar nada
      return;
    } else {
      // Mensagem padrão caso o backend não envie detalhes
      String message = 'Falha ao criar a conta.';

      if (response.body.isNotEmpty) {
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody is Map && errorBody['message'] != null) {
            message = errorBody['message'];
          }
        } catch (_) {
          // Corpo não é JSON, mantém a mensagem genérica
        }
      } else if (response.statusCode == 403) {
        message = 'Dados inválidos ou usuário já cadastrado.';
      } else if (response.statusCode == 400) {
        message = 'Requisição inválida. Verifique os campos e tente novamente.';
      }
      throw Exception(message);
    }
  }

  // MÉTODO PARA VERIFICAR TOKEN
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  // MÉTODO DE LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
  }
}
