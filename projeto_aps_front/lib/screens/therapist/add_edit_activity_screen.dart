import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/atividade.dart';
import '../../providers/therapist_provider.dart';

class AddEditActivityScreen extends StatefulWidget {
  final Atividade? atividade; // Nulo para "Adicionar", preenchido para "Editar"

  const AddEditActivityScreen({super.key, this.atividade});

  @override
  State<AddEditActivityScreen> createState() => _AddEditActivityScreenState();
}

class _AddEditActivityScreenState extends State<AddEditActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool get _isEditing => widget.atividade != null;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;
  TipoAtividade? _selectedType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.atividade?.titulo ?? '');
    _descriptionController = TextEditingController(text: widget.atividade?.descricaoDetalhada ?? '');
    _durationController = TextEditingController(text: widget.atividade?.duracaoEstimadaMinutos.toString() ?? '');
    _selectedType = widget.atividade?.tipo;
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final therapistProvider = Provider.of<TherapistProvider>(context, listen: false);

    final atividadeData = {
      "titulo": _titleController.text,
      "descricaoDetalhada": _descriptionController.text,
      "duracaoEstimadaMinutos": int.parse(_durationController.text),
      "tipo": _selectedType!.name,
    };

    try {
      if (_isEditing) {
        await therapistProvider.updateAtividade(widget.atividade!.id, atividadeData);
      } else {
        await therapistProvider.createAtividade(atividadeData);
      }
      if(mounted) Navigator.of(context).pop();
    } catch (e) {
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
        title: Text(_isEditing ? 'Editar Atividade' : 'Nova Atividade'),
        actions: [
          if (_isLoading)
            const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)))
          else
            IconButton(icon: const Icon(Icons.save), onPressed: _saveForm, tooltip: 'Salvar'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título da Atividade'),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => (v == null || v.isEmpty) ? 'Título é obrigatório.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição Detalhada'),
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => (v == null || v.isEmpty) ? 'Descrição é obrigatória.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Duração Estimada (minutos)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => (v == null || v.isEmpty) ? 'Duração é obrigatória.' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TipoAtividade>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Tipo de Atividade'),
                items: TipoAtividade.values
                  .where((tipo) => tipo != TipoAtividade.UNKNOWN) // Não mostrar 'UNKNOWN' como opção
                  .map((tipo) => DropdownMenuItem(
                    value: tipo,
                    child: Text(tipo.name),
                  )).toList(),
                onChanged: (value) => setState(() => _selectedType = value),
                validator: (v) => v == null ? 'Selecione um tipo.' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}