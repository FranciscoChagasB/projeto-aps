import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/crianca.dart';
import '../../models/plano.dart';
import '../../providers/plano_provider.dart';
import 'add_edit_plan_screen.dart';

class TherapistChildDetailScreen extends StatefulWidget {
  final Crianca crianca;

  const TherapistChildDetailScreen({super.key, required this.crianca});

  @override
  State<TherapistChildDetailScreen> createState() => _TherapistChildDetailScreenState();
}

class _TherapistChildDetailScreenState extends State<TherapistChildDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<PlanoProvider>(context, listen: false).fetchPlanosByCriancaId(widget.crianca.id));
  }

  void _navigateToAddPlan() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => AddEditPlanScreen(crianca: widget.crianca)),
    );
  }
  
  void _confirmDeletePlan(Plano plano) {
     showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza de que deseja excluir o plano "${plano.nome}"? Todos os registros associados também podem ser perdidos.'),
        actions: [
          TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(ctx).pop()),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
            onPressed: () {
              Provider.of<PlanoProvider>(context, listen: false).deletePlano(plano.id, widget.crianca.id);
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
      ),
      body: RefreshIndicator(
        onRefresh: () => Provider.of<PlanoProvider>(context, listen: false).fetchPlanosByCriancaId(widget.crianca.id),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text('Paciente: ${widget.crianca.nomeCompleto}', style: Theme.of(context).textTheme.headlineSmall),
                     const SizedBox(height: 8),
                     Text('Responsável: ${widget.crianca.responsavel.fullName}'),
                     Text('Nascimento: ${DateFormat('dd/MM/yyyy').format(widget.crianca.dataNascimento)}'),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Planos de Atividades', style: Theme.of(context).textTheme.titleLarge),
              ),
              Consumer<PlanoProvider>(
                builder: (context, planoProvider, child) {
                  if (planoProvider.isLoading && planoProvider.planos.isEmpty) {
                    return const Center(heightFactor: 5, child: CircularProgressIndicator());
                  }
                  if (planoProvider.error != null) {
                    return Center(child: Text('Erro: ${planoProvider.error}'));
                  }
                  if (planoProvider.planos.isEmpty) {
                    return const Center(heightFactor: 5, child: Text('Nenhum plano criado para esta criança.'));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: planoProvider.planos.length,
                    itemBuilder: (ctx, i) {
                      final plano = planoProvider.planos[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ExpansionTile(
                          title: Text(plano.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(plano.objetivo),
                          children: [
                            ...plano.atividades.map((ativ) => ListTile(
                              dense: true,
                              title: Text(ativ.titulo),
                              // Aqui você pode adicionar um botão para remover a atividade do plano
                            )).toList(),
                            ButtonBar(
                              alignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.add_task, color: Colors.blue),
                                  label: const Text('Adicionar Atividade'),
                                  onPressed: () { /* Lógica para abrir seletor de atividades */ },
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  label: const Text('Excluir Plano'),
                                  onPressed: () => _confirmDeletePlan(plano),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
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