import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/crianca.dart';
import '../../providers/auth_provider.dart';
import '../../providers/parent_provider.dart';
import '../auth/login_screen.dart';
import 'add_edit_child_screen.dart';
import 'child_detail_screen.dart';
import '../../widgets/welcome_card.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final GlobalKey<WelcomeCardState> _welcomeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Inicia a busca pelos dados assim que a tela é construída
    Future.microtask(() => Provider.of<ParentProvider>(context, listen: false)
        .fetchMinhasCriancas());
  }

  void _navigateToChildDetail(Crianca crianca) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ChildDetailScreen(crianca: crianca),
      ),
    );
  }

  void _navigateToAddChild() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(builder: (ctx) => const AddEditChildScreen()),
    )
        .then((_) {
      Provider.of<ParentProvider>(context, listen: false).fetchMinhasCriancas();
    });
  }

  Future<void> _refresh() async {
    await Provider.of<ParentProvider>(context, listen: false)
        .fetchMinhasCriancas();
    _welcomeKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Filhos'),
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
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WelcomeCard(key: _welcomeKey),

              const SizedBox(height: 24),
              Text('Minhas Crianças',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),

              Consumer<ParentProvider>(
                builder: (context, parentProvider, child) {
                  if (parentProvider.isLoading &&
                      parentProvider.criancas.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (parentProvider.error != null) {
                    return Center(child: Text('Erro: ${parentProvider.error}'));
                  }
                  if (parentProvider.criancas.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Nenhuma criança cadastrada.\nToque no botão "+" para adicionar seu primeiro filho.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: parentProvider.criancas.length,
                    itemBuilder: (ctx, i) {
                      final crianca = parentProvider.criancas[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 3,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: (crianca.fotoCriancaBase64 !=
                                        null &&
                                    crianca.fotoCriancaBase64!.isNotEmpty)
                                ? MemoryImage(
                                    base64Decode(crianca.fotoCriancaBase64!))
                                : null,
                            child: (crianca.fotoCriancaBase64 == null ||
                                    crianca.fotoCriancaBase64!.isEmpty)
                                ? Text(crianca.nomeCompleto.isNotEmpty
                                    ? crianca.nomeCompleto[0]
                                    : '?')
                                : null,
                          ),
                          title: Text(crianca.nomeCompleto,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              'Nascimento: ${DateFormat('dd/MM/yyyy').format(crianca.dataNascimento)}'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _navigateToChildDetail(crianca),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddChild,
        tooltip: 'Adicionar Criança',
        child: const Icon(Icons.add),
      ),
    );
  }
}
