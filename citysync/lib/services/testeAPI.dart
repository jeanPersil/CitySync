import 'package:http/http.dart' as http;
import 'dart:convert';

class TesteApi {
  Future<String> requisicao() async {
    final response = await http.get(Uri.parse('http://172.26.1.53:5000/teste'));

    if (response.statusCode == 200) {
      final dados = jsonDecode(response.body);
      return dados['mensagem'];
    } else {
      throw Exception('Falha na requisição: ${response.statusCode}');
    }
  }
}