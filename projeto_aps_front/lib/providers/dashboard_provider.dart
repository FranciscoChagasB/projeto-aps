import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/dashboard_stats.dart';
import '../services/api_client.dart';
import 'auth_provider.dart';

class DashboardProvider with ChangeNotifier {
  final Dio _dio = ApiClient().dio;
  AuthProvider? _authProvider;

  DashboardStats? stats;
  bool isLoading = false;

  String? _error;

  void update(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  Future<void> fetchEvolution(int criancaId) async {
    if (_authProvider?.isAuthenticated != true) return;
    isLoading = true;
    notifyListeners();
    _error = null;

    try {
      final response = await _dio.get('/dashboard/evolution/$criancaId');
      stats = DashboardStats.fromJson(response.data);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
