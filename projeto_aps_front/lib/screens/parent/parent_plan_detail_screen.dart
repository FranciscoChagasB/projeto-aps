import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/atividade_summary.dart';
import '../../models/plano.dart';
import '../../models/registro.dart';
import '../../providers/registro_provider.dart';

class ParentPlanDetailScreen extends StatefulWidget {
  final Plano plano;
  final int criancaId;

  const ParentPlanDetailScreen(
      {super.key, required this.plano, required this.criancaId});

  @override
  State<ParentPlanDetailScreen> createState() => _ParentPlanDetailScreenState();
}

class _ParentPlanDetailScreenState extends State<ParentPlanDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<RegistroProvider>(context, listen: false)
        .fetchRegistrosByPlanoId(widget.plano.id));
  }

  void _showRegistroSheet(
      {Registro? registro, required AtividadeSummary atividade}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: _RegistroFormBottomSheet(
            atividade: atividade,
            planoId: widget.plano.id,
            criancaId: widget.criancaId,
            registro: registro,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.plano.nome)),
      body: Consumer<RegistroProvider>(
        builder: (context, registroProvider, child) {
          try {
            if (registroProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () =>
                  registroProvider.fetchRegistrosByPlanoId(widget.plano.id),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Text(widget.plano.objetivo,
                      style: Theme.of(context).textTheme.titleMedium),
                  const Divider(height: 32),
                  ...widget.plano.atividades.map((atividade) {
                    final registroDeHoje =
                        registroProvider.registros.firstWhere(
                      (r) =>
                          r.atividade.id == atividade.id &&
                          DateUtils.isSameDay(
                              r.dataHoraConclusao, DateTime.now()),
                      orElse: () => Registro.empty(),
                    );

                    final bool isRegistrado = registroDeHoje.id != 0;

                    return Card(
                      color: isRegistrado ? Colors.green.shade50 : null,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          isRegistrado
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isRegistrado ? Colors.green : Colors.grey,
                        ),
                        title: Text(atividade.titulo,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: isRegistrado
                            ? Text(
                                'Registrado como: ${registroDeHoje.status.displayName}') // Usando displayName
                            : const Text('Pendente de registro para hoje.'),
                        onTap: () => _showRegistroSheet(
                          atividade: atividade,
                          registro: isRegistrado ? registroDeHoje : null,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
            return Center(
              child: Text('Ocorreu um erro ao renderizar esta tela: $e'),
            );
          }
        },
      ),
    );
  }
}

class _RegistroFormBottomSheet extends StatefulWidget {
  final AtividadeSummary atividade;
  final int planoId;
  final int criancaId;
  final Registro? registro;

  const _RegistroFormBottomSheet({
    required this.atividade,
    required this.planoId,
    required this.criancaId,
    this.registro,
  });

  @override
  State<_RegistroFormBottomSheet> createState() =>
      _RegistroFormBottomSheetState();
}

class _RegistroFormBottomSheetState extends State<_RegistroFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _observacoesController;
  late StatusRegistro _selectedStatus;

  @override
  void initState() {
    super.initState();
    _observacoesController = TextEditingController(
        text: widget.registro?.observacoesDoResponsavel ?? '');
    _selectedStatus = widget.registro?.status ?? StatusRegistro.CONCLUIDO;
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final registroProvider =
        Provider.of<RegistroProvider>(context, listen: false);
    try {
      if (widget.registro == null || widget.registro!.id == 0) {
        final registroData = {
          "atividadeId": widget.atividade.id,
          "planoId": widget.planoId,
          "criancaId": widget.criancaId,
          "dataHoraConclusao": DateTime.now().toIso8601String(),
          "observacoesDoResponsavel": _observacoesController.text,
          "status": _selectedStatus.name,
        };
        await registroProvider.createRegistro(registroData, widget.planoId);
      } else {
        final registroUpdateData = {
          "status": _selectedStatus.name,
          "observacoesDoResponsavel": _observacoesController.text
        };
        await registroProvider.updateRegistro(
            widget.registro!.id, registroUpdateData, widget.planoId);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.atividade.titulo,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            DropdownButtonFormField<StatusRegistro>(
              value: _selectedStatus,
              decoration:
                  const InputDecoration(labelText: 'Como foi a atividade?'),
              isExpanded:
                  true, // Garante que o item ocupe o espaço e quebre a linha se necessário
              items: StatusRegistro.values
                  .where((s) => s != StatusRegistro.UNKNOWN)
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status
                            .displayName), // Usa o nome de exibição amigável
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedStatus = value);
              },
              validator: (value) =>
                  value == null ? 'Selecione um status' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observacoesController,
              decoration: const InputDecoration(
                  labelText: 'Suas Observações (Opcional)',
                  alignLabelWithHint: true),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('Salvar Registro'),
              ),
          ],
        ),
      ),
    );
  }
}
