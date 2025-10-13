import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/cep_service.dart';

enum RoleName { PARENT, HEALTH_PROFESSIONAL, ADMINISTRATOR }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _viaCepService = ViaCepService();

  bool _isLoading = false;
  bool _isCepLoading = false;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // <-- NOVO
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  
  final _cepFocusNode = FocusNode();

  RoleName? _selectedRole = RoleName.PARENT;
  String? _selectedStateUF;

  final List<Map<String, String>> _brazilianStates = [
    {'UF': 'AC', 'Nome': 'Acre'}, {'UF': 'AL', 'Nome': 'Alagoas'},
    {'UF': 'AP', 'Nome': 'Amapá'}, {'UF': 'AM', 'Nome': 'Amazonas'},
    {'UF': 'BA', 'Nome': 'Bahia'}, {'UF': 'CE', 'Nome': 'Ceará'},
    {'UF': 'DF', 'Nome': 'Distrito Federal'}, {'UF': 'ES', 'Nome': 'Espírito Santo'},
    {'UF': 'GO', 'Nome': 'Goiás'}, {'UF': 'MA', 'Nome': 'Maranhão'},
    {'UF': 'MT', 'Nome': 'Mato Grosso'}, {'UF': 'MS', 'Nome': 'Mato Grosso do Sul'},
    {'UF': 'MG', 'Nome': 'Minas Gerais'}, {'UF': 'PA', 'Nome': 'Pará'},
    {'UF': 'PB', 'Nome': 'Paraíba'}, {'UF': 'PR', 'Nome': 'Paraná'},
    {'UF': 'PE', 'Nome': 'Pernambuco'}, {'UF': 'PI', 'Nome': 'Piauí'},
    {'UF': 'RJ', 'Nome': 'Rio de Janeiro'}, {'UF': 'RN', 'Nome': 'Rio Grande do Norte'},
    {'UF': 'RS', 'Nome': 'Rio Grande do Sul'}, {'UF': 'RO', 'Nome': 'Rondônia'},
    {'UF': 'RR', 'Nome': 'Roraima'}, {'UF': 'SC', 'Nome': 'Santa Catarina'},
    {'UF': 'SP', 'Nome': 'São Paulo'}, {'UF': 'SE', 'Nome': 'Sergipe'},
    {'UF': 'TO', 'Nome': 'Tocantins'},
  ];

  @override
  void initState() {
    super.initState();
    _cepFocusNode.addListener(_onCepFocusChange);
  }

  @override
  void dispose() {
    _cepFocusNode.removeListener(_onCepFocusChange);
    _cepFocusNode.dispose();
    // ... dispose de todos os outros controllers
    super.dispose();
  }

  void _onCepFocusChange() {
    if (!_cepFocusNode.hasFocus) {
      _fetchAddressData();
    }
  }

  Future<void> _fetchAddressData() async {
    FocusScope.of(context).unfocus(); 
    final cep = _postalCodeController.text;
    if (cep.length < 8) return;

    setState(() => _isCepLoading = true);
    try {
      final addressData = await _viaCepService.fetchAddressFromCep(cep);
      setState(() {
        _streetController.text = addressData['logradouro'] ?? '';
        _neighborhoodController.text = addressData['bairro'] ?? '';
        _cityController.text = addressData['localidade'] ?? '';
        _selectedStateUF = addressData['uf'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if(mounted) setState(() => _isCepLoading = false);
    }
  }

  Future<void> _submitRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);

    Map<String, String> addressData = {
      "street": _streetController.text, "number": _numberController.text,
      "complement": _complementController.text, "neighborhood": _neighborhoodController.text,
      "city": _cityController.text, "state": _selectedStateUF ?? '',
      "postalCode": _postalCodeController.text
    };

    Map<String, dynamic> userData = {
      "fullName": _fullNameController.text, "email": _emailController.text,
      "password": _passwordController.text, "cpf": _cpfController.text,
      "phone": _phoneController.text, "address": addressData,
      "role": _selectedRole.toString().split('.').last
    };

    try {
      await Provider.of<AuthProvider>(context, listen: false).register(userData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso! Por favor, faça o login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
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
                    // --- Seção de Dados Pessoais ---
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(labelText: 'Nome Completo'),
                      validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'E-mail'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v!.isEmpty || !v.contains('@')) ? 'E-mail inválido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Senha'),
                      obscureText: true,
                      validator: (v) => (v!.length < 6) ? 'Mínimo de 6 caracteres' : null,
                    ),
                    const SizedBox(height: 16),
                    // NOVO CAMPO DE CONFIRMAR SENHA
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(labelText: 'Confirmar Senha'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirme sua senha';
                        }
                        if (value != _passwordController.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- Seção de Endereço ---
                    const SizedBox(height: 24),
                    const Text("Endereço", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _postalCodeController,
                      focusNode: _cepFocusNode,
                      decoration: InputDecoration(
                        labelText: 'CEP',
                        helperText: 'Digite o CEP para buscar o endereço',
                        suffixIcon: _isCepLoading 
                          ? const Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2.0))
                          : IconButton(icon: const Icon(Icons.search), onPressed: _fetchAddressData),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => (v?.length ?? 0) < 8 ? 'CEP deve ter 8 dígitos' : null,
                    ),
                    // ... (outros campos de endereço)
                     const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedStateUF,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: _brazilianStates.map((state) => DropdownMenuItem<String>(
                        value: state['UF'],
                        child: Text(state['Nome']!),
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedStateUF = v),
                      validator: (v) => v == null ? 'Selecione um estado' : null,
                    ),
                    const SizedBox(height: 24),

                    // --- Seção de Perfil ---
                    DropdownButtonFormField<RoleName>(
                      value: _selectedRole,
                      decoration: const InputDecoration(labelText: 'Eu sou...'),
                      items: const [
                        DropdownMenuItem(value: RoleName.PARENT, child: Text('Pai / Responsável')),
                        DropdownMenuItem(value: RoleName.HEALTH_PROFESSIONAL, child: Text('Profissional da Saúde')),
                      ],
                      onChanged: (v) => setState(() => _selectedRole = v),
                      validator: (v) => v == null ? 'Selecione um perfil' : null,
                    ),
                    const SizedBox(height: 32),
                    
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: _submitRegister,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
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