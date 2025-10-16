import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projeto_aps_front/screens/therapist/therapist_child_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
      builder: (ctx) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final double dialogWidth = screenWidth > 600 ? 500 : screenWidth * 0.9;
        final double qrSize = screenWidth > 600 ? 250 : screenWidth * 0.5;

        return Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: dialogWidth),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text(
                    'Meu Código Profissional',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Peça para o responsável escanear este QR Code ou compartilhar o código abaixo:',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: qrSize,
                    height: qrSize,
                    child: QrImageView(
                      data: code,
                      version: QrVersions.auto,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SelectableText(
                    code,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    children: [
                      TextButton(
                        child: const Text('Copiar Código'),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: code));
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Código copiado!')),
                          );
                        },
                      ),
                      ElevatedButton(
                        child: const Text('Fechar'),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  )
                ]),
              ),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel do Terapeuta'),
        actions: [
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
      body: RefreshIndicator(
        onRefresh: () => Provider.of<TherapistProvider>(context, listen: false)
            .fetchMeusPacientes(),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Bem-vindo(a),\n${user?.fullName ?? ''}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                const double breakPoint = 400.0;
                final bool useColumnLayout = constraints.maxWidth < breakPoint;

                final actionCards = [
                  _buildActionCard(
                    context,
                    icon: Icons.library_books_outlined,
                    label: 'Biblioteca de Atividades',
                    onTap: _navigateToActivityLibrary,
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.qr_code_scanner_outlined,
                    label: 'Meu Código Profissional',
                    onTap: () =>
                        _showProfessionalCode(context, user?.professionalCode),
                  ),
                ];

                if (useColumnLayout) {
                  return Column(
                    children: [
                      actionCards[0],
                      const SizedBox(height: 16),
                      actionCards[1],
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(child: actionCards[0]),
                      const SizedBox(width: 16),
                      Expanded(child: actionCards[1]),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 32),
            Text('Meus Pacientes',
                style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 24),
            Consumer<TherapistProvider>(
              builder: (context, therapistProvider, child) {
                if (therapistProvider.isLoadingPacientes &&
                    therapistProvider.pacientes.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (therapistProvider.error != null) {
                  return Center(
                      child: Text('Erro: ${therapistProvider.error}'));
                }
                if (therapistProvider.pacientes.isEmpty) {
                  return const Center(
                      child: Text('Nenhum paciente vinculado.'));
                }

                return Column(
                  children: therapistProvider.pacientes.map((paciente) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(),
                        title: Text(paciente.nomeCompleto,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'Responsável: ${paciente.responsavel.fullName}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _navigateToPatientDetail(paciente),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
