import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:citysync/model/modelReport.dart';

class ReportApiService {
  Future<List<Report>> obterListaReports(int idUsuario) async {
    final response = await http.get(
      Uri.parse('http://192.168.0.16:5000/listar_reports/$idUsuario'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> reportsJson = jsonData['reports'];
      return reportsJson.map((r) => Report.fromJson(r)).toList();
    } else {
      throw Exception("Erro ao buscar reports: ${response.body}");
    }
  }

  Future<String?> enviarReport({
    required String endereco,
    required int categoriaId,
    required int usuarioId,
    required String descricao,
    String? urlImagem,
  }) async {
    try {
      final uri = Uri.parse('http://192.168.0.16:5000/efetuar_report');
      final body = jsonEncode({
        "endereco": endereco,
        "categoria": categoriaId,
        "id_usuario": usuarioId,
        "descricao": descricao,
        "url_imagem": urlImagem ?? "",
      });

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        return null;
      } else {
        final decoded = jsonDecode(response.body);
        final mensagemErro = decoded['erro'] ?? 'erro desconhecido';
        return mensagemErro;
      }
    } catch (e) {
      return e.toString();
    }
  }
}
