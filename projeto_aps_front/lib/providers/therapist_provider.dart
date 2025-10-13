import 'package:flutter/foundation.dart';
import '../models/atividade.dart';
import '../models/crianca.dart';
import '../services/atividade_service.dart';
import '../services/crianca_service.dart';
import 'auth_provider.dart';

class TherapistProvider with ChangeNotifier {
  final CriancaService _criancaService = CriancaService();
  final AtividadeService _atividadeService = AtividadeService();
  AuthProvider? _authProvider;

  List<Crianca> _pacientes = [];
  List<Atividade> _atividadesDaBiblioteca = [];
  bool _isLoadingPacientes = false;
  bool _isLoadingAtividades = false;
  String? _error;

  List<Crianca> get pacientes => _pacientes;
  List<Atividade> get atividadesDaBiblioteca => _atividadesDaBiblioteca;
  bool get isLoadingPacientes => _isLoadingPacientes;
  bool get isLoadingAtividades => _isLoadingAtividades;
  String? get error => _error;

  void update(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  Future<void> fetchMeusPacientes() async {
    if (_authProvider?.isAuthenticated != true) return;
    _isLoadingPacientes = true;
    _error = null;
    notifyListeners();
    try {
      _pacientes = await _criancaService.getCriancasDoTerapeuta();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingPacientes = false;
      notifyListeners();
    }
  }

  Future<void> fetchAtividadesDaBiblioteca() async {
    if (_authProvider?.isAuthenticated != true) return;
    _isLoadingAtividades = true;
    _error = null;
    notifyListeners();
    try {
      _atividadesDaBiblioteca = await _atividadeService.getAllAtividades();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingAtividades = false;
      notifyListeners();
    }
  }

  Future<void> createAtividade(Map<String, dynamic> atividadeData) async {
    if (_authProvider?.isAuthenticated != true) return;
    await _atividadeService.createAtividade(atividadeData);
    await fetchAtividadesDaBiblioteca(); // Atualiza a lista
  }

  Future<void> updateAtividade(int id, Map<String, dynamic> atividadeData) async {
    if (_authProvider?.isAuthenticated != true) return;
    await _atividadeService.updateAtividade(id, atividadeData);
    await fetchAtividadesDaBiblioteca(); // Atualiza a lista
  }

  Future<void> deleteAtividade(int id) async {
    if (_authProvider?.isAuthenticated != true) return;
    await _atividadeService.deleteAtividade(id);
    await fetchAtividadesDaBiblioteca(); // Atualiza a lista
  }
}