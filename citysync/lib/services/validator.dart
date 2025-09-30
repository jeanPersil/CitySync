import 'dart:convert';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:http/http.dart' as http;

class Validator {
  validarCPF(String cpf) {
    if (cpf.isEmpty) {
      return "O cpf é obrigatorio";
    }

    final String numeros = cpf.replaceAll(RegExp(r'\D'), '');

    if (!CPFValidator.isValid(cpf)) {
      return false;
    }
    return true;
  }

  validarCEP(String cep) async {
    final url = Uri.parse("https://viacep.com.br/ws/$cep/json/");

    final response = await http.get(url).timeout(const Duration(seconds: 5));

    if (response == 200) {
      final Map<String, dynamic> dados = jsonDecode(response.body);
      if (dados.containsKey("erro") && dados["erro"] == true) {
        return false;
      }
      return true;
    }
  }
}
