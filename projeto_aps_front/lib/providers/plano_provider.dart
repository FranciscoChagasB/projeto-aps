import 'package:flutter/foundation.dart';
import '../models/plano.dart';
import '../services/plano_service.dart';
import 'auth_provider.dart';

class PlanoProvider with ChangeNotifier {
  final PlanoService _planoService = PlanoService();
  AuthProvider? _authProvider;

  List<Plano> _planos = [];
  bool _isLoading = false;
  String? _error;

  List<Plano> get planos => _planos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void update(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  Future<void> fetchPlanosByCriancaId(int criancaId) async {
    if (_authProvider?.isAuthenticated != true) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _planos = await _planoService.getPlanosByCrianca(criancaId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPlano(Map<String, dynamic> planoData, int criancaId) async {
     if (_authProvider?.isAuthenticated != true) return;
     // Idealmente, um loading local na tela de formulário
     await _planoService.createPlano(planoData);
     // Atualiza a lista de planos após criar um novo
     await fetchPlanosByCriancaId(criancaId);
  }

  Future<void> deletePlano(int planoId, int criancaId) async {
    if (_authProvider?.isAuthenticated != true) return;
    await _planoService.deletePlano(planoId);
    await fetchPlanosByCriancaId(criancaId);
  }
  
}