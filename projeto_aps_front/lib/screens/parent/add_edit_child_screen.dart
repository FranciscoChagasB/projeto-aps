import 'dart:convert';
import 'dart:io' show File;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/crianca.dart';
import '../../providers/parent_provider.dart';

class AddEditChildScreen extends StatefulWidget {
  final Crianca? crianca;

  const AddEditChildScreen({super.key, this.crianca});

  @override
  State<AddEditChildScreen> createState() => _AddEditChildScreenState();
}

class _AddEditChildScreenState extends State<AddEditChildScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _diagnosticDescriptionController;
  late TextEditingController _additionalInfoController;
  DateTime? _selectedDate;

  XFile? _pickedImage;
  PlatformFile? _pickedPdf;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.crianca?.nomeCompleto ?? '');
    _diagnosticDescriptionController =
        TextEditingController(text: widget.crianca?.descricaoDiagnostico ?? '');
    _additionalInfoController = TextEditingController(
        text: widget.crianca?.informacoesAdicionais ?? '');
    _selectedDate = widget.crianca?.dataNascimento;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _diagnosticDescriptionController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedXFile = await _picker.pickImage(
        source: source, imageQuality: 50, maxWidth: 800);
    if (pickedXFile != null) {
      setState(() {
        _pickedImage = pickedXFile;
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Câmera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // Importante para a web!
    );
    if (result != null) {
      setState(() {
        _pickedPdf = result.files.single;
      });
    }
  }

  Future<void> _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      // A configuração de locale no main.dart fará isso funcionar.
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Por favor, selecione a data de nascimento.')));
      }
      return;
    }

    setState(() => _isLoading = true);

    final parentProvider = Provider.of<ParentProvider>(context, listen: false);

    String? imageBase64;
    if (_pickedImage != null) {
      final bytes = await _pickedImage!.readAsBytes();
      imageBase64 = base64Encode(bytes);
    }

    String? pdfBase64;
    if (_pickedPdf != null) {
      pdfBase64 = base64Encode(_pickedPdf!.bytes!);
    }

    final criancaData = {
      "nomeCompleto": _nameController.text,
      "dataNascimento": DateFormat('yyyy-MM-dd').format(_selectedDate!),
      "descricaoDiagnostico": _diagnosticDescriptionController.text,
      "informacoesAdicionais": _additionalInfoController.text,
      "fotoCrianca": imageBase64,
      "anexoDiagnostico": pdfBase64,
      "terapeutaIds":
          widget.crianca?.terapeutas.map((t) => t.id).toList() ?? [],
    };

    try {
      String successMessage;
      Crianca updatedCrianca;

      if (widget.crianca == null) {
        final newCrianca = await parentProvider.createCrianca(criancaData);
        updatedCrianca = newCrianca; // Atribuindo a criança criada
        successMessage = 'Criança adicionada com sucesso!';
      } else {
        final updatedCriancaResponse =
            await parentProvider.updateCrianca(widget.crianca!.id, criancaData);
        updatedCrianca =
            updatedCriancaResponse; // Atribuindo a criança atualizada
        successMessage = 'Alterações salvas com sucesso!';
      }

      if (mounted) {
        Navigator.of(context).pop(updatedCrianca);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(successMessage), backgroundColor: Colors.green),
        );
      }
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
        title: Text(
            widget.crianca == null ? 'Adicionar Criança' : 'Editar Criança'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // --- UI PARA FOTO DA CRIANÇA ---
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _buildAvatarImage(),
                          child: _pickedImage == null &&
                                  widget.crianca?.fotoCriancaBase64 == null
                              ? const Icon(Icons.person, size: 60)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 20),
                              onPressed: _showImagePickerOptions,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: 'Nome Completo'),
                    // ... (resto do TextFormField)
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: _presentDatePicker,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data de Nascimento',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            _selectedDate == null
                                ? 'Selecione uma data'
                                : DateFormat('dd/MM/yyyy')
                                    .format(_selectedDate!),
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _diagnosticDescriptionController,
                    decoration: const InputDecoration(
                        labelText: 'Descrição do Diagnóstico (Opcional)'),
                  ),
                  const SizedBox(height: 24),

                  // --- UI PARA ANEXO DO DIAGNÓSTICO ---
                  OutlinedButton.icon(
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Anexar Laudo em PDF'),
                    onPressed: _pickPdf,
                  ),
                  if (_pickedPdf != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Arquivo selecionado: ${_pickedPdf!.name}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade700)),
                    ),

                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _additionalInfoController,
                    decoration: const InputDecoration(
                      labelText: 'Informações Adicionais (Opcional)',
                      hintText: 'Ex: Alergias, preferências...',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            // --- Botão de Salvar ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: Text(widget.crianca == null
                          ? 'Adicionar Criança'
                          : 'Salvar Alterações'),
                      onPressed: _saveForm,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _buildAvatarImage() {
    // Se uma nova imagem foi selecionada
    if (_pickedImage != null) {
      // Se for web, o 'path' é uma URL, então usamos NetworkImage.
      if (kIsWeb) {
        return NetworkImage(_pickedImage!.path);
      }
      // Se não for web (mobile/desktop), o 'path' é um caminho de arquivo,
      // então podemos usar a classe 'File' do 'dart:io'.
      return FileImage(File(_pickedImage!.path));
    }
    // Se não há nova imagem, mas há uma imagem existente salva (em Base64)
    if (widget.crianca?.fotoCriancaBase64 != null) {
      // MemoryImage funciona em todas as plataformas.
      return MemoryImage(base64Decode(widget.crianca!.fotoCriancaBase64!));
    }
    // Se não há nenhuma imagem, retorna nulo.
    return null;
  }
}
