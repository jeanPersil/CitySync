import 'dart:typed_data';
import 'dart:io' as io;
import 'package:citysync/model/model_report.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class ReportApiService {
  final supabase = Supabase.instance.client;

  // Coordenadas aproximadas dos limites de Feira de Santana
  static const double _minLatitude = -12.35;
  static const double _maxLatitude = -12.15; // Ajustado levemente para cobrir melhor a zona norte
  static const double _minLongitude = -39.10;
  static const double _maxLongitude = -38.80;
  
  static const int tamanhoDaPagina = 10;
  static const String _bucketName = 'imagens';

  /// Faz o upload da imagem (suporta Web e Mobile via Bytes ou File)
  Future<String?> uploadImagem({
    io.File? imageFile,
    Uint8List? imageBytes,
    required String imageName,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // Remove caracteres especiais do nome do arquivo para evitar erro na URL
      final safeName = imageName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '');
      final nomeArquivo = '${timestamp}_$safeName';

      // 1. Tenta enviar via BYTES (funciona em Web e Mobile se passarmos os bytes)
      if (imageBytes != null) {
        await supabase.storage.from(_bucketName).uploadBinary(
          nomeArquivo,
          imageBytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg', // Força o tipo para garantir visualização
            upsert: false,
          ),
        );
      } 
      // 2. Fallback: Tenta enviar via ARQUIVO (apenas Mobile/Desktop IO)
      else if (imageFile != null) {
        await supabase.storage.from(_bucketName).upload(
          nomeArquivo,
          imageFile,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ),
        );
      } else {
        if (kDebugMode) print("Nenhuma imagem fornecida para upload.");
        return null;
      }

      // 3. Pega a URL pública
      final urlPublica = supabase.storage
          .from(_bucketName)
          .getPublicUrl(nomeArquivo);

      return urlPublica;
    } catch (e) {
      if (kDebugMode) {
        print("❌ Erro ao fazer upload da imagem: $e");
      }
      return null;
    }
  }

  /// Busca reports paginados de um usuário específico
  Future<List<Report>> obterListaReports(String idUsuario, int pagina) async {
    try {
      final int from = (pagina - 1) * tamanhoDaPagina;
      final int to = (pagina * tamanhoDaPagina) - 1;

      final response = await supabase
          .from("listar_reportes") // Certifique-se que essa VIEW ou TABELA existe
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
      if (kDebugMode) {
        print("Erro ao buscar reports do usuário: $e");
      }
      return [];
    }
  }

  /// Busca todos os reports (Admin/Feed) e filtra por FSA
  Future<List<Report>> obterTodosReports() async {
    try {
      final response = await supabase
          .from("listar_reportes")
          .select()
          .order('data_criacao', ascending: false)
          .limit(100); // ADICIONADO LIMIT: Segurança para não travar se houver 1 milhão de reports

      if (response.isEmpty) {
        return [];
      }

      final todosReports = (response as List)
          .map((item) => Report.fromJson(item as Map<String, dynamic>))
          .toList();

      return _filtrarPorFeiraDeSantana(todosReports);
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao buscar todos os reports: $e");
      }
      return [];
    }
  }

  // Filtra localmente os reports (idealmente isso seria no banco, mas funciona aqui)
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

  /// Envia o report para o banco de dados
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
      // Validação básica
      if (endereco.isEmpty || categoriaId == 0) {
        return "Endereço e categoria são obrigatórios.";
      }

      // Validação Geográfica
      if (!_estaEmFeiraDeSantana(latitude, longitude)) {
        return "Localização fora de Feira de Santana. Reporte apenas na cidade.";
      }
      
      if (latitude == 0.0 && longitude == 0.0) {
        return "GPS inválido.";
      }

      // Inserção no banco
      await supabase.from("reportes").insert({
        'endereco': endereco,
        'fk_categoria': categoriaId,
        'fk_usuario': usuarioId,
        'descricao': descricao,
        'url_imagem': urlImagem ?? '',
        'latitude': latitude,
        'longitude': longitude,
        // O campo 'status' e 'data_criacao' devem ter defaults no banco (ex: 'Pendente', now())
      });

      return null; // Null significa sucesso
    } on PostgrestException catch (e) {
      return "Erro do banco de dados: ${e.message}";
    } catch (e) {
      return "Erro inesperado: $e";
    }
  }
}