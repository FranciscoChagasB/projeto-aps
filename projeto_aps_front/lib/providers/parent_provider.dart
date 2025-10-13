import 'package:flutter/foundation.dart';
import '../models/crianca.dart';
import '../services/crianca_service.dart';
import 'auth_provider.dart';

class ParentProvider with ChangeNotifier {
  final CriancaService _criancaService = CriancaService();
  AuthProvider? _authProvider; // Dependência do AuthProvider para pegar o token

  List<Crianca> _criancas = [];
  bool _isLoading = false;
  String? _error;

  List<Crianca> get criancas => _criancas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Método para receber a instância do AuthProvider
  void update(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  // Busca a lista de crianças associadas à conta do responsável.
  Future<void> fetchMinhasCriancas() async {
    if (_authProvider?.isAuthenticated != true) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _criancas = await _criancaService.getMinhasCriancas();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Adiciona uma nova criança.
  Future<void> createCrianca(Map<String, dynamic> criancaData) async {
    if (_authProvider?.isAuthenticated != true) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _criancaService.createCrianca(criancaData);
      // Após criar, atualiza a lista para refletir a mudança na UI.
      await fetchMinhasCriancas();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Vincula um terapeuta a uma criança.
  Future<void> vincularTerapeuta(int criancaId, String professionalCode) async {
    if (_authProvider?.isAuthenticated != true) return;
    // Não precisa de loading global, pode ter um loading local no botão
    
    try {
      await _criancaService.vincularTerapeuta(criancaId, professionalCode);
      // Atualiza a lista para que a UI mostre o novo terapeuta.
      await fetchMinhasCriancas();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Método para atualizar uma criança
  Future<void> updateCrianca(int criancaId, Map<String, dynamic> criancaData) async {
    if (_authProvider?.isAuthenticated != true) return;

    try {
      await _criancaService.updateCrianca(criancaId, criancaData);
      // Após atualizar, busca a lista novamente para garantir consistência.
      await fetchMinhasCriancas();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }
  
}