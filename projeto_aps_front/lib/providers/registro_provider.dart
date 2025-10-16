import 'package:flutter/foundation.dart';
import '../models/registro.dart';
import '../services/registro_service.dart';
import 'auth_provider.dart';

class RegistroProvider with ChangeNotifier {
  final RegistroService _registroService = RegistroService();
  AuthProvider? _authProvider;

  List<Registro> _registros = [];
  bool _isLoading = false;
  String? _error;

  List<Registro> get registros => _registros;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void update(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  Future<void> fetchRegistrosByPlanoId(int planoId) async {
    if (_authProvider?.isAuthenticated != true) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _registros = await _registroService.getRegistrosByPlano(planoId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createRegistro(
      Map<String, dynamic> registroData, int planoId) async {
    if (_authProvider?.isAuthenticated != true) return;
    try {
      await _registroService.createRegistro(registroData);
      // Atualiza a lista após criar um novo registro
      await fetchRegistrosByPlanoId(planoId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> updateObservacoes(
      int registroId, String observacoes, int planoId) async {
    if (_authProvider?.isAuthenticated != true) return;
    try {
      await _registroService.updateObservacoes(registroId, observacoes);
      await fetchRegistrosByPlanoId(planoId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> updateRegistro(
      int registroId, Map<String, dynamic> data, int planoId) async {
    await _registroService.updateRegistro(registroId, data);
    await fetchRegistrosByPlanoId(planoId);
  }
}
