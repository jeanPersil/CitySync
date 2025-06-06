import 'package:http/http.dart' as http;
import 'dart:convert';

class AutenticacaoUsuario {
  Future<Map<String, dynamic>> login(String email, String senha) async {
    final String _urlBase = "http://192.168.0.17:5000/login";
    try {
      final resposta = await http.post(
        Uri.parse(_urlBase),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "senha": senha,
        }),
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        return {
          "sucesso": true,
          "usuario": dados["usuario"],
        };
      } else {
        final erro = jsonDecode(resposta.body);
        return {
          "sucesso": false,
          "mensagem": erro["erro"] ?? "Erro desconhecido",
        };
      }
    } catch (e) {
      return {
        "sucesso": false,
        "mensagem": "Erro de conexão: $e",
      };
    }
  }



  


  
}
