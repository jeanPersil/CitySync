class Report {
  final int id;
  final String endereco;
  final String nomeCategoria;
  final String nomeStatus;
  final int idUsuario;
  final String duracao;
  final String urlImagem;
  final String dataCriacao;

  Report({
    required this.id,
    required this.endereco,
    required this.nomeCategoria,
    required this.nomeStatus,
    required this.idUsuario,
    required this.duracao,
    required this.urlImagem,
    required this.dataCriacao,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      endereco: json['endereco'] ?? '',
      nomeCategoria: json['categoria'] ?? '',
      nomeStatus: json['status'] ?? '',
      idUsuario: json['id_usuario'] ?? 0,
      duracao: (json['duracao'] ?? 0).toString(),
      urlImagem: json['url_imagem'] ?? '',
      dataCriacao: json['data_report'] ?? '',
    );
  }
}
