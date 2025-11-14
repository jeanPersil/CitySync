import 'dart:convert';
import 'dart:async';
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

  Future<bool> validarCepComApi(String cep) async {
    try {
      String cepLimpo = cep.replaceAll(RegExp(r'\D'), '');

      if (cepLimpo.length != 8) return false;

      if (RegExp(r'^(\d)\1{7}$').hasMatch(cepLimpo)) return false;

      final url = Uri.parse("https://viacep.com.br/ws/$cepLimpo/json/");
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["erro"] != true &&
            data["logradouro"] != null &&
            data["logradouro"].toString().trim().isNotEmpty;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
