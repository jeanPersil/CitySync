import 'dart:typed_data';
import 'dart:io' as io;
import 'package:citysync/model/model_report.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ReportApiService {
  final supabase = Supabase.instance.client;

  // Coordenadas aproximadas dos limites de Feira de Santana
  static const double _minLatitude = -12.35;
  static const double _maxLatitude = -12.20;
  static const double _minLongitude = -39.10;
  static const double _maxLongitude = -38.80;
  static const int tamanhoDaPagina = 10;

  static const String _bucketName = 'imagens';

  
  Future<String?> uploadImagem({
    io.File? imageFile,
    Uint8List? imageBytes,
    required String imageName,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extensao = imageName.split('.').last;
      final nomeArquivo = '${timestamp}_$imageName';

      String caminho;

      if (kIsWeb && imageBytes != null) {
        caminho = await supabase.storage
            .from(_bucketName)
            .uploadBinary(nomeArquivo, imageBytes);
      } else if (imageFile != null) {
        caminho = await supabase.storage
            .from(_bucketName)
            .upload(nomeArquivo, imageFile);
      } else {
        return null;
      }

      final urlPublica = supabase.storage
          .from(_bucketName)
          .getPublicUrl(nomeArquivo);

      return urlPublica;
    } catch (e) {
      print("Erro ao fazer upload da imagem: $e");
      return null;
    }
  }

  
  Future<List<Report>> obterListaReports(String idUsuario, int pagina) async {
    try {
      final int from = (pagina - 1) * tamanhoDaPagina;
      final int to = (pagina * tamanhoDaPagina) - 1;

      final response = await supabase
          .from("listar_reportes")
          .select()
          .eq('fk_usuario', idUsuario)
          .order('data_criacao', ascending: false)
          .range(from, to);

      if (response.isEmpty) {
        return [];
      }

      final reportsDaPagina = (response as List)
          .map((item) => Report.fromJson(item as Map<String, dynamic>))
          .toList();

      return reportsDaPagina;
    } catch (e) {
      print("Erro ao buscar reports do usuário: $e");
      return [];
    }
  }

  /// Busca todos os reports e filtra por Feira de Santana
  Future<List<Report>> obterTodosReports() async {
    try {
      final response = await supabase
          .from("listar_reportes")
          .select()
          .order('data_criacao', ascending: false);

      if (response.isEmpty) {
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

 
  List<Report> _filtrarPorFeiraDeSantana(List<Report> reports) {
    return reports.where((report) {
      return _estaEmFeiraDeSantana(report.latitude, report.longitude);
    }).toList();
  }

  
  bool _estaEmFeiraDeSantana(double latitude, double longitude) {
    return latitude >= _minLatitude &&
        latitude <= _maxLatitude &&
        longitude >= _minLongitude &&
        longitude <= _maxLongitude;
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
      // Validação básica de campos obrigatórios
      if (endereco.isEmpty || categoriaId == 0) {
        return "Endereço e categoria são obrigatórios.";
      }

      
      if (!_estaEmFeiraDeSantana(latitude, longitude)) {
        return "A localização GPS está fora dos limites de Feira de Santana. "
            "Apenas reports dentro da cidade são permitidos.";
      }

      
      if (latitude == 0.0 && longitude == 0.0) {
        return "Coordenadas GPS inválidas. Por favor, ative sua localização.";
      }

    

      // Inserção no banco de dados
      await supabase.from("reportes").insert({
        'endereco': endereco,
        'fk_categoria': categoriaId,
        'fk_usuario': usuarioId,
        'descricao': descricao,
        'url_imagem': urlImagem ?? '',
        'latitude': latitude,
        'longitude': longitude,
      });

      return null; // Sucesso
    } on PostgrestException catch (e) {
      return "Erro do banco de dados: ${e.message}";
    } catch (e) {
      return "Erro inesperado ao enviar report: $e";
    }
  }

  
  bool validarLocalizacao(double latitude, double longitude) {
    // Verifica se não são coordenadas padrão/inválidas
    if (latitude == 0.0 && longitude == 0.0) {
      return false;
    }

    // Verifica se está dentro dos limites da cidade
    return _estaEmFeiraDeSantana(latitude, longitude);
  }

  
  String obterMensagemErroLocalizacao(double latitude, double longitude) {
    if (latitude == 0.0 && longitude == 0.0) {
      return "Não foi possível obter sua localização. "
          "Verifique se o GPS está ativado e se o app tem permissão de localização.";
    }

    if (!_estaEmFeiraDeSantana(latitude, longitude)) {
      return "Você está fora de Feira de Santana. "
          "Este app aceita apenas reports dentro dos limites da cidade.\n\n"
          "Sua localização atual:\n"
          "Latitude: ${latitude.toStringAsFixed(6)}\n"
          "Longitude: ${longitude.toStringAsFixed(6)}";
    }

    return "Localização válida.";
  }
}