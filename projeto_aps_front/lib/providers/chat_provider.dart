import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/api_client.dart';
import 'auth_provider.dart';

class ChatProvider with ChangeNotifier {
  final Dio _dio = ApiClient().dio;
  AuthProvider? _authProvider;
  
  List<ChatMessage> messages = [];
  bool isLoading = false;
  Timer? _timer;

  String? _error;

  void update(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  // Inicia o Polling (busca automática a cada 5s)
  void startPolling(int criancaId) {
    fetchMessages(criancaId); // Busca imediata
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => fetchMessages(criancaId));
  }

  void stopPolling() {
    _timer?.cancel();
  }

  Future<void> fetchMessages(int criancaId) async {
    if (_authProvider?.isAuthenticated != true) return;
    try {
      final response = await _dio.get('/chat/$criancaId');
      messages = (response.data as List).map((e) => ChatMessage.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> sendMessage(int criancaId, String content) async {
    try {
      await _dio.post('/chat', data: {"criancaId": criancaId, "content": content});
      await fetchMessages(criancaId); // Atualiza imediatamente após enviar
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}