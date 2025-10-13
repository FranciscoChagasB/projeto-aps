import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio _dio;

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal()
      : _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080')) {// 10.0.2.2 = localhost)
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Antes de cada requisição (exceto login/registro que não precisam de token),
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('authToken');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // Libera a requisição para continuar.
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          print('Erro na requisição: ${e.response?.statusCode}');
          print('Resposta do erro: ${e.response?.data}');

          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}