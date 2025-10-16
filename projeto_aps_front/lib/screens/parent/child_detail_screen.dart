import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto_aps_front/screens/parent/parent_plan_detail_screen.dart';
import 'package:projeto_aps_front/screens/parent/qr_code_scanner_screen.dart';
import 'package:provider/provider.dart';
import '../../models/crianca.dart';
import '../../providers/parent_provider.dart';
import '../../providers/plano_provider.dart';
import 'add_edit_child_screen.dart';

class ChildDetailScreen extends StatefulWidget {
  final Crianca crianca;

  const ChildDetailScreen({super.key, required this.crianca});

  @override
  State<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen> {
  late Crianca _criancaAtual;
  @override
  void initState() {
    super.initState();
    _criancaAtual = widget.crianca;

    // Busca os planos associados a esta criança
    Future.microtask(() {
      Provider.of<PlanoProvider>(context, listen: false)
          .fetchPlanosByCriancaId(_criancaAtual.id);
    });
  }

  void _showVincularTerapeutaDialog() {
    final codeController = TextEditingController();

    void _navigateToScanner() async {
      final codeFromScanner = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (ctx) => const QrCodeScannerScreen()),
      );
      if (codeFromScanner != null) {
        codeController.text = codeFromScanner;
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vincular Terapeuta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: codeController,
              decoration:
                  const InputDecoration(labelText: 'Código do Profissional'),
            ),
            const SizedBox(height: 16),
            // --- NOVO BOTÃO DE SCANNER ---
            OutlinedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Escanear QR Code'),
              onPressed: () {
                Navigator.of(ctx)
                    .pop(); // Fecha o dialog antes de abrir o scanner
                _navigateToScanner();
              },
            )
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text('Vincular'),
            onPressed: () async {
              if (codeController.text.isEmpty) return;
              final parentProvider =
                  Provider.of<ParentProvider>(context, listen: false);
              try {
                await parentProvider.vincularTerapeuta(
                    _criancaAtual.id, codeController.text);
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Terapeuta vinculado com sucesso!'),
                        backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Crianca crianca) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
            'Tem certeza de que deseja excluir o perfil de ${crianca.nomeCompleto}? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop()),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
            onPressed: () async {
              final parentProvider =
                  Provider.of<ParentProvider>(context, listen: false);
              try {
                await parentProvider.deleteCrianca(crianca.id);
                if (mounted) {
                  Navigator.of(ctx).pop(); // Fecha o dialog
                  Navigator.of(context).pop(); // Volta para o dashboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('${crianca.nomeCompleto} foi excluído(a).'),
                        backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _navigateToEditScreen(Crianca crianca) async {
    final updatedCrianca = await Navigator.of(context).push<Crianca>(
      MaterialPageRoute(
        builder: (ctx) => AddEditChildScreen(crianca: crianca),
      ),
    );

    if (updatedCrianca != null) {
      setState(() {
        _criancaAtual = updatedCrianca;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ParentProvider>(builder: (context, parentProvider, child) {
      // Encontrar a criança mais recente a partir do Provider
      final criancaAtualizada = parentProvider.criancas.firstWhere(
        (c) => c.id == _criancaAtual.id,
        orElse: () => _criancaAtual, // Fallback caso não encontre a criança
      );

      return Scaffold(
        appBar: AppBar(
          title: Text(_criancaAtual.nomeCompleto),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar Dados',
              onPressed: () => _navigateToEditScreen(criancaAtualizada),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Excluir Criança',
              onPressed: () => _confirmDelete(criancaAtualizada),
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => Provider.of<PlanoProvider>(context, listen: false)
              .fetchPlanosByCriancaId(criancaAtualizada.id),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card com detalhes da criança
                Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Detalhes',
                            style: Theme.of(context).textTheme.titleLarge),
                        const Divider(),
                        Text(
                            'Data de Nascimento: ${DateFormat('dd/MM/yyyy').format(_criancaAtual.dataNascimento)}'),
                        if (_criancaAtual.descricaoDiagnostico?.isNotEmpty ??
                            false)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                                'Diagnóstico: ${_criancaAtual.descricaoDiagnostico}'),
                          ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Terapeutas Vinculados',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                const Divider(indent: 16, endIndent: 16),
                if (criancaAtualizada.terapeutas.isEmpty)
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                    child: Center(child: Text('Nenhum terapeuta vinculado.')),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: criancaAtualizada.terapeutas.length,
                    itemBuilder: (ctx, i) {
                      final terapeuta = criancaAtualizada.terapeutas[i];
                      return ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(terapeuta.fullName),
                        subtitle: Text(terapeuta.email),
                      );
                    },
                  ),
                const SizedBox(height: 24),

                // Seção de Planos de Atividades
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Planos de Atividades',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                const Divider(indent: 16, endIndent: 16),
                Consumer<PlanoProvider>(
                  builder: (context, planoProvider, child) {
                    if (planoProvider.isLoading) {
                      return const Center(
                          heightFactor: 5, child: CircularProgressIndicator());
                    }
                    if (planoProvider.error != null) {
                      return Center(
                          child: Text('Erro: ${planoProvider.error}'));
                    }
                    if (planoProvider.planos.isEmpty) {
                      return const Center(
                          heightFactor: 5,
                          child:
                              Text('Nenhum plano atribuído a esta criança.'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: planoProvider.planos.length,
                      itemBuilder: (ctx, i) {
                        final plano = planoProvider.planos[i];
                        return ListTile(
                          title: Text(plano.nome,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(plano.objetivo),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ParentPlanDetailScreen(
                                  plano: plano,
                                  criancaId: widget.crianca.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showVincularTerapeutaDialog,
          label: const Text('Vincular Terapeuta'),
          icon: const Icon(Icons.link),
        ),
      );
    });
  }
}
