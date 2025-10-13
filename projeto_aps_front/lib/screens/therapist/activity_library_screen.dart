import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/atividade.dart';
import '../../providers/therapist_provider.dart';
import 'add_edit_activity_screen.dart';

class ActivityLibraryScreen extends StatefulWidget {
  const ActivityLibraryScreen({super.key});

  @override
  State<ActivityLibraryScreen> createState() => _ActivityLibraryScreenState();
}

class _ActivityLibraryScreenState extends State<ActivityLibraryScreen> {

  @override
  void initState() {
    super.initState();
     Future.microtask(() =>
        Provider.of<TherapistProvider>(context, listen: false).fetchAtividadesDaBiblioteca());
  }

  void _navigateToAddEditActivity([Atividade? atividade]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => AddEditActivityScreen(atividade: atividade)),
    ).then((success) {
      // Se a tela de edição retornar sucesso, atualizamos a lista
      if (success == true) {
        Provider.of<TherapistProvider>(context, listen: false).fetchAtividadesDaBiblioteca();
      }
    });
  }

  void _confirmDelete(Atividade atividade) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza de que deseja excluir a atividade "${atividade.titulo}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
            onPressed: () async {
              try {
                await Provider.of<TherapistProvider>(context, listen: false).deleteAtividade(atividade.id);
                if (mounted) Navigator.of(ctx).pop();
              } catch (e) {
                if (mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                }
              }
            },
          ),
        ],
      ),
    );
  }

  IconData _getIconForActivityType(TipoAtividade tipo) {
    switch (tipo) {
      case TipoAtividade.LUDICA: return Icons.sports_esports_outlined;
      case TipoAtividade.EDUCACIONAL: return Icons.school_outlined;
      case TipoAtividade.TERAPEUTICA: return Icons.healing_outlined;
      case TipoAtividade.FISICA: return Icons.fitness_center_outlined;
      default: return Icons.task_alt_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca de Atividades'),
      ),
      body: Consumer<TherapistProvider>(
        builder: (context, therapistProvider, child) {
          if (therapistProvider.isLoadingAtividades && therapistProvider.atividadesDaBiblioteca.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (therapistProvider.error != null) {
            return Center(child: Text('Erro: ${therapistProvider.error}'));
          }
          if (therapistProvider.atividadesDaBiblioteca.isEmpty) {
            return const Center(child: Text('Nenhuma atividade na sua biblioteca. Toque em "+" para criar a primeira.'));
          }

          return RefreshIndicator(
            onRefresh: () => therapistProvider.fetchAtividadesDaBiblioteca(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: therapistProvider.atividadesDaBiblioteca.length,
              itemBuilder: (ctx, i) {
                final atividade = therapistProvider.atividadesDaBiblioteca[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(_getIconForActivityType(atividade.tipo)),
                    ),
                    title: Text(atividade.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Duração: ${atividade.duracaoEstimadaMinutos} min - ${atividade.tipo.name}'),
                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined), SizedBox(width: 8), Text('Editar')])),
                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline), SizedBox(width: 8), Text('Excluir')])),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateToAddEditActivity(atividade);
                        } else if (value == 'delete') {
                           _confirmDelete(atividade);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditActivity(),
        tooltip: 'Nova Atividade',
        child: const Icon(Icons.add),
      ),
    );
  }
}