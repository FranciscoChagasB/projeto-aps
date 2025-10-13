import 'package:flutter/foundation.dart';
import 'package:projeto_aps_front/providers/auth_provider.dart';
import '../models/user_admin.dart';
import '../services/admin_service.dart';
import 'package:logging/logging.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();
  final Logger _logger = Logger('AdminService');
  AuthProvider? _authProvider; 

  List<UserAdmin> _users = [];
  bool _isLoading = false;
  String? _error;

  List<UserAdmin> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void update(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  Future<void> fetchUsers() async {
    if (_authProvider?.isAuthenticated != true) return;

    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _users = await _adminService.getAllUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserStatus(int userId, bool isActive) async {
    if (_authProvider?.isAuthenticated != true) return;

    // Salva o estado original para reverter em caso de erro
    final originalStatus = _users.firstWhere((user) => user.id == userId).isActive;
    
    // Atualiza a UI imediatamente para uma experiência mais fluida
    final index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _users[index].isActive = isActive;
      notifyListeners();
    }

    try {
      // Tenta atualizar no backend
      await _adminService.updateUserStatus(userId, isActive);
    } catch (e) {
      // Se der erro no backend, reverte a mudança na UI e notifica o erro
      if (index != -1) {
        _users[index].isActive = originalStatus;
        notifyListeners();
      }
      _logger.severe('Falha ao atualizar status', e);
    }
  }
}