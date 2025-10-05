import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/cep_service.dart';

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
  final _viaCepService = ViaCepService();

  bool _isLoading = false;
  bool _isCepLoading = false;

  // Controllers para os dados do usuário
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();

  // Controllers para o Endereço
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  // Busca do cep pela api
  final _cepFocusNode = FocusNode();

  RoleName? _selectedRole = RoleName.PARENT; // Valor inicial
  String? _selectedStateUF; // Select dos estados

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

  Future<void> _fetchAddressData() async {
    // Esconde o teclado para melhor visualização do loading e dos campos preenchidos
    FocusScope.of(context).unfocus(); 

    final cep = _postalCodeController.text;
    if (cep.length < 8) return;

    setState(() => _isCepLoading = true);
    try {
      final addressData = await _viaCepService.fetchAddressFromCep(cep);
      
      // Preenche os controllers com os dados da API
      setState(() {
        _streetController.text = addressData['logradouro'] ?? '';
        _neighborhoodController.text = addressData['bairro'] ?? '';
        _cityController.text = addressData['localidade'] ?? '';
        // Seleciona o estado correto no Dropdown
        _selectedStateUF = addressData['uf'];
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isCepLoading = false);
    }
  }

  void _onCepFocusChange() {
    // Se o campo CEP perdeu o foco, tentamos buscar o endereço
    if (!_cepFocusNode.hasFocus) {
      _fetchAddressData();
    }
  }

  @override
  void initState() {
    super.initState();
    _cepFocusNode.addListener(_onCepFocusChange);
  }

  @override
  void dispose() {
    // Limpeza dos controllers
    _cepFocusNode.removeListener(_onCepFocusChange);
    _cepFocusNode.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Ajustando endereço
      Map<String, String> addressData = {
        "street": _streetController.text,
        "number": _numberController.text,
        "complement": _complementController.text,
        "neighborhood": _neighborhoodController.text,
        "city": _cityController.text,
        "state": _selectedStateUF ?? '',
        "postalCode": _postalCodeController.text
      };

      Map<String, dynamic> userData = {
        "fullName": _fullNameController.text,
        "email": _emailController.text,
        "password": _passwordController.text,
        "cpf": _cpfController.text,
        "phone": _phoneController.text,
        "address": addressData, // Agora é uma entidade, não uma string
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
                    const SizedBox(height: 16),

                    const Text("Endereço", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _postalCodeController,
                      focusNode: _cepFocusNode,
                      decoration: InputDecoration(
                        labelText: 'CEP',
                        helperText: 'Digite o CEP para buscar o endereço', // Texto de ajuda
                        suffixIcon: _isCepLoading 
                          ? const Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2.0)) 
                          : IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: _fetchAddressData, // Botão para busca manual também
                            ),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => (value?.length ?? 0) < 8 ? 'CEP deve ter 8 dígitos' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _streetController,
                      decoration: const InputDecoration(labelText: 'Rua / Logradouro'),
                      validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _numberController,
                      decoration: const InputDecoration(labelText: 'Número'),
                      validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _complementController,
                      decoration: const InputDecoration(labelText: 'Complemento (Opcional)'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _neighborhoodController,
                      decoration: const InputDecoration(labelText: 'Bairro'),
                      validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'Cidade'),
                      validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedStateUF,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: _brazilianStates.map((state) {
                        return DropdownMenuItem<String>(
                          value: state['UF'],
                          child: Text(state['Nome']!),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() { _selectedStateUF = newValue; });
                      },
                      validator: (value) => value == null || value.isEmpty ? 'Selecione um estado' : null,
                    ),
                    const SizedBox(height: 24),

                    const Text("Tipo de Usuário", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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