class Report {
  final int id;
  final String endereco;
  final String nomeCategoria;
  final String nomeStatus;
  final String idUsuario;
  final String urlImagem;
  final String dataCriacao;

  Report({
    required this.id,
    required this.endereco,
    required this.nomeCategoria,
    required this.nomeStatus,
    required this.idUsuario,
    required this.urlImagem,
    required this.dataCriacao,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? 0,
      endereco: json['endereco'] ?? '',
      nomeCategoria: json['categoria'] ?? '',
      nomeStatus: json['status'] ?? '',
      idUsuario: json['id_usuario'] ?? '',
      urlImagem: json['url_imagem'] ?? '',
      dataCriacao: json['data_report'] ?? '',
    );
  }
}
