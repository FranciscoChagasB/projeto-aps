import 'dart:convert';
import 'package:http/http.dart' as http;

class ViaCepService {
  Future<Map<String, dynamic>> fetchAddressFromCep(String cep) async {
    // Remove qualquer caractere que não seja número do CEP
    final cepSanitized = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cepSanitized.length != 8) {
      throw Exception('CEP inválido. Deve conter 8 dígitos.');
    }

    final uri = Uri.parse('https://viacep.com.br/ws/$cepSanitized/json/');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // A API do ViaCEP retorna um { "erro": true } para CEPs que não existem.
      if (data['erro'] == true) {
        throw Exception('CEP não encontrado.');
      }
      return data;
    } else {
      throw Exception('Não foi possível buscar o CEP. Tente novamente.');
    }
  }
}