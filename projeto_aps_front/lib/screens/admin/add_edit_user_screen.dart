import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_admin.dart';
import '../../providers/admin_provider.dart';

class AddEditUserScreen extends StatefulWidget {
  final UserAdmin? user;

  const AddEditUserScreen({super.key, this.user});

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool get _isEditing => widget.user != null;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isActive = true;
  String _selectedRole = 'PARENT';

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _fullNameController.text = widget.user!.fullName;
      _emailController.text = widget.user!.email;
      _cpfController.text = widget.user!.cpf ?? '';
      _phoneController.text = widget.user!.phone ?? '';
      _isActive = widget.user!.isActive;
      _selectedRole =
          widget.user!.roles.isNotEmpty ? widget.user!.roles.first : 'PARENT';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    final userData = {
      "fullName": _fullNameController.text,
      "email": _emailController.text,
      "cpf": _cpfController.text,
      "phone": _phoneController.text,
      "active": _isActive,
      "role": _selectedRole,
    };

    try {
      if (_isEditing) {
        await adminProvider.updateUser(widget.user!.id, userData);
      } else {
        await adminProvider.createUser(userData);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Usuário' : 'Novo Usuário'),
      ),
      body: Form(
        key: _formKey,
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Nome Completo'),
                  validator: (v) => v!.isEmpty ? 'Nome é obrigatório' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v!.isEmpty || !v.contains('@'))
                      ? 'Email inválido'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _cpfController,
                    decoration: const InputDecoration(labelText: 'CPF')),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Telefone')),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Perfil'),
                  items: const [
                    DropdownMenuItem(
                        value: 'PARENT', child: Text('Pai / Responsável')),
                    DropdownMenuItem(
                        value: 'HEALTH_PROFESSIONAL',
                        child: Text('Profissional de Saúde')),
                    DropdownMenuItem(
                        value: 'ADMINISTRATOR', child: Text('Administrador')),
                  ],
                  onChanged: (value) => setState(() => _selectedRole = value!),
                  validator: (v) => v == null ? 'Perfil é obrigatório' : null,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Usuário Ativo'),
                  value: _isActive,
                  onChanged: (newValue) => setState(() => _isActive = newValue),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: Text(
                        _isEditing ? 'Salvar Alterações' : 'Criar Usuário'),
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
          ),
        ]),
      ),
    );
  }
}
