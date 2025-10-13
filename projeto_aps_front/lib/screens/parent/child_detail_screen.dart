import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  @override
  void initState() {
    super.initState();
    // Busca os planos associados a esta criança
    Future.microtask(() => Provider.of<PlanoProvider>(context, listen: false)
        .fetchPlanosByCriancaId(widget.crianca.id));
  }

  void _showVincularTerapeutaDialog() {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vincular Terapeuta'),
        content: TextField(
          controller: codeController,
          decoration:
              const InputDecoration(labelText: 'Código do Profissional'),
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
                    widget.crianca.id, codeController.text);
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

  void _navigateToEditScreen(Crianca crianca) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AddEditChildScreen(crianca: crianca),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Para garantir que os dados estejam sempre atualizados, ouvimos o provider
    final parentProvider = Provider.of<ParentProvider>(context);
    // Encontramos a versão mais recente da criança na lista do provider
    final criancaAtualizada = parentProvider.criancas.firstWhere(
      (c) => c.id == widget.crianca.id,
      orElse: () =>
          widget.crianca, // Fallback para o objeto inicial se não encontrar
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.crianca.nomeCompleto),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar Dados',
            onPressed: () => _navigateToEditScreen(criancaAtualizada),
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
                          'Data de Nascimento: ${DateFormat('dd/MM/yyyy').format(widget.crianca.dataNascimento)}'),
                      if (widget.crianca.descricaoDiagnostico?.isNotEmpty ??
                          false)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                              'Diagnóstico: ${widget.crianca.descricaoDiagnostico}'),
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
                    return Center(child: Text('Erro: ${planoProvider.error}'));
                  }
                  if (planoProvider.planos.isEmpty) {
                    return const Center(
                        heightFactor: 5,
                        child: Text('Nenhum plano atribuído a esta criança.'));
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
                          // TODO: Navegar para a tela de detalhes do plano,
                          // onde o pai poderá registrar as atividades.
                          // Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlanDetailScreen(plano: plano)));
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
  }
}
