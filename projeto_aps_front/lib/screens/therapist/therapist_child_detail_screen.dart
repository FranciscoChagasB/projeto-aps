import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto_aps_front/providers/therapist_provider.dart';
import 'package:projeto_aps_front/screens/common/ai_report_screen.dart';
import 'package:projeto_aps_front/screens/common/chat_screen.dart';
import 'package:projeto_aps_front/screens/common/evolution_charts_widget.dart';
import 'package:provider/provider.dart';
import '../../models/crianca.dart';
import '../../models/plano.dart';
import '../../providers/plano_provider.dart';
import 'add_edit_plan_screen.dart';

class TherapistChildDetailScreen extends StatefulWidget {
  final Crianca crianca;

  const TherapistChildDetailScreen({super.key, required this.crianca});

  @override
  State<TherapistChildDetailScreen> createState() =>
      _TherapistChildDetailScreenState();
}

class _TherapistChildDetailScreenState
    extends State<TherapistChildDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<PlanoProvider>(context, listen: false)
        .fetchPlanosByCriancaId(widget.crianca.id));
    Provider.of<TherapistProvider>(context, listen: false)
        .fetchAtividadesDaBiblioteca();
  }

  void _navigateToAddPlan() {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (ctx) => AddEditPlanScreen(crianca: widget.crianca)),
    );
  }

  void _confirmDeletePlan(Plano plano) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
            'Tem certeza de que deseja excluir o plano "${plano.nome}"? Todos os registros associados também podem ser perdidos.'),
        actions: [
          TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(ctx).pop()),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
            onPressed: () {
              Provider.of<PlanoProvider>(context, listen: false)
                  .deletePlano(plano.id, widget.crianca.id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.crianca.nomeCompleto),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Relatório IA'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => AiReportScreen(
                      criancaId: widget.crianca.id,
                      nomeCrianca: widget.crianca.nomeCompleto,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => Provider.of<PlanoProvider>(context, listen: false)
            .fetchPlanosByCriancaId(widget.crianca.id),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EvolutionChartsWidget(criancaId: widget.crianca.id),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat com Responsável'),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 45)),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ChatScreen(
                            criancaId: widget.crianca.id,
                            titulo: "Chat - ${widget.crianca.nomeCompleto}")));
                  },
                ),
              ),

              const Divider(),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Paciente: ${widget.crianca.nomeCompleto}',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('Responsável: ${widget.crianca.responsavel.fullName}'),
                    Text(
                        'Nascimento: ${DateFormat('dd/MM/yyyy').format(widget.crianca.dataNascimento)}'),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Planos de Atividades',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              Consumer<PlanoProvider>(
                builder: (context, planoProvider, child) {
                  if (planoProvider.isLoading && planoProvider.planos.isEmpty) {
                    return const Center(
                        heightFactor: 5, child: CircularProgressIndicator());
                  }
                  if (planoProvider.error != null) {
                    return Center(child: Text('Erro: ${planoProvider.error}'));
                  }
                  if (planoProvider.planos.isEmpty) {
                    return const Center(
                        heightFactor: 5,
                        child: Text('Nenhum plano criado para esta criança.'));
                  }

                  return Column(
                    children: planoProvider.planos.map((plano) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ExpansionTile(
                          title: Text(plano.nome,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(plano.objetivo),
                          children: [
                            ...plano.atividades
                                .map((ativ) => ListTile(
                                      dense: true,
                                      title: Text(ativ.titulo),
                                    ))
                                .toList(),
                            ButtonBar(
                              alignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.add_task,
                                      color: Colors.blue),
                                  label: const Text('Adicionar Atividade'),
                                  onPressed: () {
                                    /* Lógica para abrir seletor de atividades */
                                  },
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  label: const Text('Excluir Plano'),
                                  onPressed: () => _confirmDeletePlan(plano),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 80), // Espaço para o FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddPlan,
        label: const Text('Novo Plano'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
