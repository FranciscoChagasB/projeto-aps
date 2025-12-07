import 'package:flutter/foundation.dart';
import '../services/ai_service.dart';
import 'auth_provider.dart';

class AiReportProvider with ChangeNotifier {
  final AiService _aiService = AiService();
  AuthProvider? _authProvider;

  // Cache: Mapeia o ID da criança para o texto do relatório e o timestamp
  final Map<int, _CachedReport> _reportCache = {};
  
  // Tempo de expiração do cache (ex: 60 segundos)
  static const Duration _cacheDuration = Duration(seconds: 60);

  bool _isLoading = false;
  bool _isDownloading = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isDownloading => _isDownloading;
  String? get error => _error;

  void update(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  // Busca o relatório (do cache ou da API)
  Future<String?> getReport(int criancaId) async {
    if (_authProvider?.isAuthenticated != true) return null;

    // 1. Verificar Cache
    final cached = _reportCache[criancaId];
    if (cached != null && DateTime.now().difference(cached.timestamp) < _cacheDuration) {
      return cached.content; // Retorna do cache se ainda for válido
    }

    // 2. Se não estiver em cache ou expirou, busca da API
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final reportText = await _aiService.generateReportText(criancaId);
      
      // Salva no cache
      _reportCache[criancaId] = _CachedReport(
        content: reportText,
        timestamp: DateTime.now(),
      );
      
      return reportText;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> downloadFile(int criancaId, String format) async {
    if (_authProvider?.isAuthenticated != true) return null;
    
    _isDownloading = true;
    notifyListeners();

    try {
      return await _aiService.downloadReport(criancaId, format);
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }
}

class _CachedReport {
  final String content;
  final DateTime timestamp;

  _CachedReport({required this.content, required this.timestamp});
}