import 'package:citysync/model/modelReport.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportApiService {
  final supabase = Supabase.instance.client;

  Future<List<Report>> obterListaReports(String idUsuario) async {
    final response = await supabase
        .from("listar_reportes")
        .select()
        .eq("fk_usuario", idUsuario);

    if (response == null || response.isEmpty) {
      return [];
    }
    return (response as List)
        .map((item) => Report.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<String?> enviarReport({
    required String endereco,
    required int categoriaId,
    required String usuarioId,
    required String descricao,
    String? urlImagem,
    required double latitude, //  ADICIONADO
    required double longitude, //  ADICIONADO
  }) async {
    try {
      if (endereco.isEmpty || categoriaId == 0) {
        return "Endereço e categoria são obrigatórios.";
      }

      await supabase.from("reportes").insert({
        'endereco': endereco,
        'fk_categoria': categoriaId,
        'fk_usuario': usuarioId,
        'descricao': descricao,
        'url_imagem': urlImagem,
        'latitude': latitude, // ⬅️ ADICIONADO
        'longitude': longitude, // ⬅️ ADICIONADO
      });
      return null; // sucesso
    } on PostgrestException catch (e) {
      return "Erro do banco: ${e.message}";
    } catch (e) {
      return "Exceção inesperada: $e";
    }
  }
}
