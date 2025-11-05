import 'package:google_maps_flutter/google_maps_flutter.dart';

class Report {
  final int id;
  final String endereco;
  final double latitude;
  final double longitude;
  final String nomeCategoria;
  final String nomeStatus;
  final String idUsuario;
  final String urlImagem;
  final String dataCriacao;
  final String descricao;

  Report({
    required this.id,
    required this.endereco,
    required this.latitude,
    required this.longitude,
    required this.nomeCategoria,
    required this.nomeStatus,
    required this.idUsuario,
    required this.urlImagem,
    required this.dataCriacao,
    required this.descricao,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? 0,
      endereco: json['endereco'] ?? '',
      latitude: (json['latitude'] is String) 
          ? double.tryParse(json['latitude']) ?? 0.0 
          : (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] is String)
          ? double.tryParse(json['longitude']) ?? 0.0
          : (json['longitude'] ?? 0.0).toDouble(),
      nomeCategoria: json['nome_categoria'] ?? '',
      nomeStatus: json['nome_status'] ?? '',
      idUsuario: json['fk_usuario'] ?? '',
      urlImagem: json['url_imagem'] ?? '',
      dataCriacao: json['data_criacao'] ?? '',
      descricao: json['descricao'] ?? '',
    );
  }

  
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }
}