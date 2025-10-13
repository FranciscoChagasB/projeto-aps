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

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Inicia a busca pelos dados assim que a tela é construída
    Future.microtask(() =>
        Provider.of<ParentProvider>(context, listen: false).fetchMinhasCriancas());
  }

  void _navigateToChildDetail(Crianca crianca) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ChildDetailScreen(crianca: crianca),
      ),
    );
  }

  void _navigateToAddChild() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const AddEditChildScreen()),
    ).then((_) {
      // Atualiza a lista quando retorna da tela de adição
      Provider.of<ParentProvider>(context, listen: false).fetchMinhasCriancas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Bem-vindo(a), ${user?.fullName ?? user?.email ?? ''}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: Consumer<ParentProvider>(
              builder: (context, parentProvider, child) {
                if (parentProvider.isLoading && parentProvider.criancas.isEmpty) {
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

                return RefreshIndicator(
                  onRefresh: () => parentProvider.fetchMinhasCriancas(),
                  child: ListView.builder(
                    itemCount: parentProvider.criancas.length,
                    itemBuilder: (ctx, i) {
                      final crianca = parentProvider.criancas[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 3,
                        child: ListTile(
                          // MUDANÇA: Exibindo a foto da criança
                          leading: CircleAvatar(
                            backgroundImage: (crianca.fotoCriancaBase64 != null && crianca.fotoCriancaBase64!.isNotEmpty)
                                ? MemoryImage(base64Decode(crianca.fotoCriancaBase64!))
                                : null,
                            child: (crianca.fotoCriancaBase64 == null || crianca.fotoCriancaBase64!.isEmpty)
                                ? Text(crianca.nomeCompleto.isNotEmpty ? crianca.nomeCompleto[0] : '?')
                                : null,
                          ),
                          title: Text(crianca.nomeCompleto, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Nascimento: ${DateFormat('dd/MM/yyyy').format(crianca.dataNascimento)}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _navigateToChildDetail(crianca),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddChild,
        tooltip: 'Adicionar Criança',
        child: const Icon(Icons.add),
      ),
    );
  }
}