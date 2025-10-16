import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/crianca.dart';
import '../../providers/plano_provider.dart';
import '../../providers/therapist_provider.dart';

class AddEditPlanScreen extends StatefulWidget {
  final Crianca crianca;

  const AddEditPlanScreen({super.key, required this.crianca});

  @override
  State<AddEditPlanScreen> createState() => _AddEditPlanScreenState();
}

class _AddEditPlanScreenState extends State<AddEditPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _objectiveController = TextEditingController();
  final Set<int> _selectedActivityIds =
      {}; // Usamos um Set para evitar IDs duplicados

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<TherapistProvider>(context, listen: false)
            .fetchAtividadesDaBiblioteca());
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
        const SnackBar(
            content: Text('Selecione pelo menos uma atividade.'),
            backgroundColor: Colors.orange),
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
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Plano de Atividades'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Plano para: ${widget.crianca.nomeCompleto}',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration:
                              const InputDecoration(labelText: 'Nome do Plano'),
                          validator: (v) =>
                              v!.isEmpty ? 'Campo obrigatório' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _objectiveController,
                          decoration: const InputDecoration(
                              labelText: 'Objetivo do Plano'),
                          validator: (v) =>
                              v!.isEmpty ? 'Campo obrigatório' : null,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Selecione as Atividades',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Consumer<TherapistProvider>(
                    builder: (context, therapistProvider, child) {
                      if (therapistProvider.isLoadingAtividades) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (therapistProvider.atividadesDaBiblioteca.isEmpty) {
                        return const Center(
                            child:
                                Text('Nenhuma atividade na sua biblioteca.'));
                      }
                      return Column(
                        children: therapistProvider.atividadesDaBiblioteca
                            .map((atividade) {
                          final isSelected =
                              _selectedActivityIds.contains(atividade.id);
                          return CheckboxListTile(
                            title: Text(atividade.titulo),
                            subtitle:
                                Text('${atividade.duracaoEstimadaMinutos} min'),
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
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Criar Plano'),
                        onPressed: _saveForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
