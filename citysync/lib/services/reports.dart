import 'package:citysync/model/modelReport.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportApiService {
  final supabase = Supabase.instance.client;

  // Coordenadas aproximadas dos limites de Feira de Santana
  static const double _minLatitude = -12.35;
  static const double _maxLatitude = -12.20;
  static const double _minLongitude = -39.10;
  static const double _maxLongitude = -38.80;

  
  Future<List<Report>> obterListaReports(String idUsuario) async {
    final response = await supabase
        .from("listar_reportes")
        .select()
        .eq("fk_usuario", idUsuario);

    if (response == null || response.isEmpty) {
      return [];
    }
    
    
    final todosReports = (response as List)
        .map((item) => Report.fromJson(item as Map<String, dynamic>))
        .toList();
    
    return _filtrarPorFeiraDeSantana(todosReports);
  }

 
  Future<List<Report>> obterTodosReports() async {
    try {
      final response = await supabase
          .from("listar_reportes")
          .select()
          .order('data_criacao', ascending: false);

      if (response == null || response.isEmpty) {
        return [];
      }
      
      final todosReports = (response as List)
          .map((item) => Report.fromJson(item as Map<String, dynamic>))
          .toList();
      
      return _filtrarPorFeiraDeSantana(todosReports);
    } catch (e) {
      print("Erro ao buscar todos os reports: $e");
      return [];
    }
  }

  // MÉTODO PARA FILTRAR REPORTS POR FEIRA DE SANTANA
  List<Report> _filtrarPorFeiraDeSantana(List<Report> reports) {
    return reports.where((report) {
      return _estaEmFeiraDeSantana(report.latitude, report.longitude);
    }).toList();
  }

  // MÉTODO PARA VERIFICAR SE AS COORDENADAS ESTÃO EM FEIRA DE SANTANA
  bool _estaEmFeiraDeSantana(double latitude, double longitude) {
    return latitude >= _minLatitude &&
           latitude <= _maxLatitude &&
           longitude >= _minLongitude &&
           longitude <= _maxLongitude;
  }

  
  bool _validarEnderecoFeiraDeSantana(String endereco) {
    final enderecoLower = endereco.toLowerCase();
    return enderecoLower.contains('feira de santana') ||
           enderecoLower.contains('feira santana') ||
           enderecoLower.contains('fsa');
  }

  Future<String?> enviarReport({
    required String endereco,
    required int categoriaId,
    required String usuarioId,
    required String descricao,
    String? urlImagem,
    required double latitude,
    required double longitude,
  }) async {
    try {
      if (endereco.isEmpty || categoriaId == 0) {
        return "Endereço e categoria são obrigatórios.";
      }

      
      if (!_estaEmFeiraDeSantana(latitude, longitude)) {
        return "Apenas são permitidos reports dentro dos limites de Feira de Santana.";
      }

      
      if (!_validarEnderecoFeiraDeSantana(endereco)) {
        return "O endereço deve estar localizado em Feira de Santana.";
      }

      await supabase.from("reportes").insert({
        'endereco': endereco,
        'fk_categoria': categoriaId,
        'fk_usuario': usuarioId,
        'descricao': descricao,
        'url_imagem': urlImagem,
        'latitude': latitude,
        'longitude': longitude,
      });
      return null; // sucesso
    } on PostgrestException catch (e) {
      return "Erro do banco: ${e.message}";
    } catch (e) {
      return "Exceção inesperada: $e";
    }
  }
}