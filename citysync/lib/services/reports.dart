import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:citysync/model/modelReport.dart';

class ReportApiService {
  Future<List<Report>> obterListaReports(int idUsuario) async {
    final response = await http.post(
      Uri.parse('http://192.168.0.4:5000/listar_reports'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"id_usuario": idUsuario}),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> reportsJson = jsonData['reports'];
      return reportsJson.map((r) => Report.fromJson(r)).toList();
    } else {
      throw Exception("Erro ao buscar reports: ${response.body}");
    }
  }

  Future<bool> enviarReport({
    required String endereco,
    required int categoriaId,
    required int usuarioId,
    required String duracao,
    required String descricao,
    String? urlImagem,
  }) async {
    final response = await http.post(
      Uri.parse('http://192.168.0.4:5000/efetuar_report'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "endereco": endereco,
        "categoria": categoriaId,
        "id_usuario": usuarioId,
        "duracao": duracao,
        "descricao": descricao,
        "url_imagem": urlImagem ?? "",
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print("Erro ao enviar report: ${response.body}");
      return false;
    }
  }
}
