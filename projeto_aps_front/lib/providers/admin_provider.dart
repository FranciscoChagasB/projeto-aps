import 'package:flutter/foundation.dart';
import 'package:projeto_aps_front/providers/auth_provider.dart';
import '../models/user_admin.dart';
import '../services/admin_service.dart';
import 'package:logging/logging.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();
  AuthProvider? _authProvider;

  List<UserAdmin> _users = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _currentFilters = {};

  List<UserAdmin> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void update(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  Future<void> fetchUsers({Map<String, dynamic>? filters}) async {
    if (_authProvider?.isAuthenticated != true) return;

    // Se novos filtros são passados, atualiza. Se não, usa os últimos aplicados.
    if (filters != null) {
      _currentFilters = filters;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // CORREÇÃO: Passa os filtros corretamente para o serviço
      _users = await _adminService.getAllUsers(filters: _currentFilters);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    if (_authProvider?.isAuthenticated != true) return;
    try {
      await _adminService.createUser(userData);
      // CORREÇÃO: Atualiza a lista após a criação, mantendo os filtros
      await fetchUsers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser(int userId, Map<String, dynamic> userData) async {
    if (_authProvider?.isAuthenticated != true) return;
    try {
      await _adminService.updateUser(userId, userData);
      // CORREÇÃO: Atualiza a lista após a edição, mantendo os filtros
      await fetchUsers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(int userId) async {
    if (_authProvider?.isAuthenticated != true) return;
    try {
      await _adminService.deleteUser(userId);
      _users.removeWhere((user) => user.id == userId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
