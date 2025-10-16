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

  Future<void> _handleRequest(int criancaId, Future<void> Function() requestFunc) async {
    if (_authProvider?.isAuthenticated != true) return;
    try {
      await requestFunc();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      await fetchPlanosByCriancaId(criancaId);
    }
  }

  Future<void> fetchPlanosByCriancaId(int criancaId) async {
    if (_authProvider?.isAuthenticated != true) return;
    _isLoading = true;
    _error = null;
    if (_planos.isEmpty) notifyListeners();
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
    await _handleRequest(criancaId, () async {
      await _planoService.createPlano(planoData);
    });
  }

  Future<void> deletePlano(int planoId, int criancaId) async {
    await _handleRequest(criancaId, () async {
      await _planoService.deletePlano(planoId);
    });
  }
  
  Future<void> updatePlano(int planoId, Map<String, dynamic> planoUpdateData, int criancaId) async {
    await _handleRequest(criancaId, () async {
      await _planoService.updatePlano(planoId, planoUpdateData);
    });
  }

  Future<void> addAtividades(int planoId, List<int> atividadeIds, int criancaId) async {
    await _handleRequest(criancaId, () async {
      await _planoService.addAtividadesAoPlano(planoId, atividadeIds);
    });
  }
  
  Future<void> removeAtividade(int planoId, int atividadeId, int criancaId) async {
    await _handleRequest(criancaId, () async {
      await _planoService.removeAtividadesDoPlano(planoId, [atividadeId]);
    });
  }
  
}