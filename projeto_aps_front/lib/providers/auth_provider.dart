import 'package:flutter/foundation.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  String? _token;
  User? _user;
  bool _isLoading = false;
  String? _error;

  // Getters para a UI acessar o estado de forma segura
  String? get token => _token;
  User? get user => _user;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Tenta fazer login, salva o token e decodifica os dados do usuário.
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authService.login(email, password);
      _token = token;
      _decodeTokenAndSetUser(token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);
    } catch (e) {
      _error = e.toString();
      rethrow; // Lança o erro novamente para a UI poder tratá-lo (ex: mostrar SnackBar)
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Tenta registrar um novo usuário.
  Future<void> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.register(userData);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // Verifica se há um token salvo para fazer o login automático.
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('authToken')) {
      return false;
    }

    final storedToken = prefs.getString('authToken')!;
    
    // Verificar a data de expiração do token
    if (Jwt.isExpired(storedToken)) {
      await logout();
      return false;
    }

    _token = storedToken;
    _decodeTokenAndSetUser(storedToken);
    notifyListeners();
    return true;
  }

  /// Desloga o usuário, limpando o token e os dados.
  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    notifyListeners();
  }

  /// Método privado para decodificar o token e extrair os dados do usuário.
  void _decodeTokenAndSetUser(String token) {
    try {
      final Map<String, dynamic> payload = Jwt.parseJwt(token);
      _user = User.fromJson(payload);
    } catch (e) {
      print('Erro ao decodificar o token: $e');
      // Em caso de erro, deslogar para segurança
      logout();
    }
  }
}