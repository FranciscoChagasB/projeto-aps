import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projeto_aps_front/screens/therapist/therapist_child_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../models/crianca.dart';
import '../../providers/auth_provider.dart';
import '../../providers/therapist_provider.dart';
import '../auth/login_screen.dart';
import 'activity_library_screen.dart';

class TherapistDashboardScreen extends StatefulWidget {
  const TherapistDashboardScreen({super.key});

  @override
  State<TherapistDashboardScreen> createState() =>
      _TherapistDashboardScreenState();
}

class _TherapistDashboardScreenState extends State<TherapistDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<TherapistProvider>(context, listen: false)
            .fetchMeusPacientes());
  }

  void _navigateToActivityLibrary() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const ActivityLibraryScreen()),
    );
  }

  void _navigateToPatientDetail(Crianca crianca) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => TherapistChildDetailScreen(crianca: crianca),
      ),
    );
  }

  void _showProfessionalCode(BuildContext context, String? code) {
    if (code == null || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código profissional não encontrado.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Seu Código Profissional'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Compartilhe este código com os responsáveis para que eles possam vincular você aos seus filhos:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SelectableText(
              code,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Copiar'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Código copiado para a área de transferência!')),
              );
            },
          ),
          ElevatedButton(
            child: const Text('Fechar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pacientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_books_outlined),
            tooltip: 'Biblioteca de Atividades',
            onPressed: _navigateToActivityLibrary,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bem-vindo(a), ${user?.fullName ?? ''}!',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gerencie seus pacientes e planos de atividades.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code_2, size: 30),
                  tooltip: 'Mostrar meu código',
                  onPressed: () =>
                      _showProfessionalCode(context, user?.professionalCode),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Consumer<TherapistProvider>(
              builder: (context, therapistProvider, child) {
                if (therapistProvider.isLoadingPacientes) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (therapistProvider.error != null) {
                  return Center(
                      child: Text('Erro: ${therapistProvider.error}'));
                }
                if (therapistProvider.pacientes.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Nenhum paciente vinculado à sua conta.\nCompartilhe seu código de profissional com os responsáveis.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => therapistProvider.fetchMeusPacientes(),
                  child: ListView.builder(
                    itemCount: therapistProvider.pacientes.length,
                    itemBuilder: (ctx, i) {
                      final paciente = therapistProvider.pacientes[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: (paciente.fotoCriancaBase64 !=
                                        null &&
                                    paciente.fotoCriancaBase64!.isNotEmpty)
                                ? MemoryImage(
                                    base64Decode(paciente.fotoCriancaBase64!))
                                : null,
                            child: (paciente.fotoCriancaBase64 == null ||
                                    paciente.fotoCriancaBase64!.isEmpty)
                                ? Text(paciente.nomeCompleto.isNotEmpty
                                    ? paciente.nomeCompleto[0]
                                    : '?')
                                : null,
                          ),
                          title: Text(paciente.nomeCompleto,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              'Responsável: ${paciente.responsavel.fullName}'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _navigateToPatientDetail(paciente),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
