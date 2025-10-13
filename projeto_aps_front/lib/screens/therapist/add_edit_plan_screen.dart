import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/atividade.dart';
import '../../models/crianca.dart';
import '../../providers/plano_provider.dart';
import '../../providers/therapist_provider.dart';

class AddEditPlanScreen extends StatefulWidget {
  final Crianca crianca;
  // final Plano? plano; // Descomente para adicionar a lógica de edição

  const AddEditPlanScreen({super.key, required this.crianca});

  @override
  State<AddEditPlanScreen> createState() => _AddEditPlanScreenState();
}

class _AddEditPlanScreenState extends State<AddEditPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  final _nameController = TextEditingController();
  final _objectiveController = TextEditingController();
  final Set<int> _selectedActivityIds = {}; // Usamos um Set para evitar IDs duplicados

  @override
  void initState() {
    super.initState();
    // Garante que a biblioteca de atividades esteja carregada
    Future.microtask(() =>
        Provider.of<TherapistProvider>(context, listen: false).fetchAtividadesDaBiblioteca());
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _objectiveController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedActivityIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos uma atividade.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    final planoProvider = Provider.of<PlanoProvider>(context, listen: false);

    final planoData = {
      "nome": _nameController.text,
      "objetivo": _objectiveController.text,
      "criancaId": widget.crianca.id,
      "atividadeIds": _selectedActivityIds.toList(),
    };

    try {
      await planoProvider.createPlano(planoData, widget.crianca.id);
      if(mounted) Navigator.of(context).pop();
    } catch(e) {
      if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Plano de Atividades'),
        actions: [
           if (_isLoading)
            const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)))
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _saveForm, tooltip: 'Salvar Plano'),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Plano para: ${widget.crianca.nomeCompleto}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nome do Plano'),
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _objectiveController,
                    decoration: const InputDecoration(labelText: 'Objetivo do Plano'),
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Selecione as Atividades', style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              child: Consumer<TherapistProvider>(
                builder: (context, therapistProvider, child) {
                  if (therapistProvider.isLoadingAtividades) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (therapistProvider.atividadesDaBiblioteca.isEmpty) {
                    return const Center(child: Text('Nenhuma atividade na sua biblioteca. Adicione atividades primeiro.'));
                  }
                  
                  return ListView.builder(
                    itemCount: therapistProvider.atividadesDaBiblioteca.length,
                    itemBuilder: (ctx, i) {
                      final atividade = therapistProvider.atividadesDaBiblioteca[i];
                      final isSelected = _selectedActivityIds.contains(atividade.id);
                      return CheckboxListTile(
                        title: Text(atividade.titulo),
                        subtitle: Text('${atividade.duracaoEstimadaMinutos} min'),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedActivityIds.add(atividade.id);
                            } else {
                              _selectedActivityIds.remove(atividade.id);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}