import 'package:flutter/material.dart';
import '../services/auth_service.dart';

// RoleNames do backend
enum RoleName { PARENT, HEALTH_PROFESSIONAL, ADMINISTRATOR }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _isLoading = false;

  // Controllers para cada campo
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  RoleName? _selectedRole = RoleName.PARENT; // Valor inicial

  @override
  void dispose() {
    // Limpeza dos controllers
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Map<String, dynamic> userData = {
        "fullName": _fullNameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "cpf": _cpfController.text,
        "phone": _phoneController.text,
        "address": _addressController.text,
        "city": _cityController.text,
        "state": _stateController.text,
        "role": _selectedRole.toString().split('.').last
      };

      try {
        await _authService.register(userData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso! Você já pode fazer o login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(); // Volta para a tela de login
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Bem-vindo(a)!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Preencha os dados abaixo para continuar.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(labelText: 'Nome Completo'),
                      validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'E-mail'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value!.isEmpty || !value.contains('@') ? 'E-mail inválido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Senha'),
                      obscureText: true,
                      validator: (value) => value!.length < 6 ? 'A senha deve ter no mínimo 6 caracteres' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cpfController,
                      decoration: const InputDecoration(labelText: 'CPF'),
                      keyboardType: TextInputType.number,
                       validator: (value) => value!.length != 11 ? 'CPF deve ter 11 dígitos' : null,
                    ),
                     const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Telefone'),
                      keyboardType: TextInputType.phone,
                      validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    /*

                      OUTROS CAMPOS A SEREM ADICIONADOS

                    */
                    const SizedBox(height: 16),

                    DropdownButtonFormField<RoleName>(
                      value: _selectedRole,
                      decoration: const InputDecoration(labelText: 'Eu sou...'),
                      items: const [
                        DropdownMenuItem(
                          value: RoleName.PARENT,
                          child: Text('Pai / Responsável'),
                        ),
                        DropdownMenuItem(
                          value: RoleName.HEALTH_PROFESSIONAL,
                          child: Text('Profissional da Saúde'),
                        ),
                      ],
                      onChanged: (RoleName? newValue) {
                        setState(() {
                          _selectedRole = newValue;
                        });
                      },
                      validator: (value) => value == null ? 'Selecione um perfil' : null,
                    ),
                    const SizedBox(height: 32),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _register,
                            child: const Text('Criar Conta'),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}