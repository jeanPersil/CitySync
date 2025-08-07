from repositories import report_repository

def efetuar_report(dados):
    return report_repository.inserir_report(
        dados['endereco'],
        dados['categoria'],
        dados['duracao'],
        dados['descricao'],
        dados['url_imagem'],
        dados['id_usuario']
    )


def listar_reports(id_usuario):
    resultados = report_repository.buscar_reports_por_usuario(id_usuario)
    reports = [{
        "id": linha["id"],
        "endereco": linha["endereco"],
        "categoria": linha["nome_categoria"],
        "status": linha["nome_status"],
        "id_usuario": linha["usuario_id"],
        "duracao": linha["duracao"],
        "url_imagem": linha["url_imagem"],
        "data_report": linha["data_criacao"]
    } for linha in resultados]
    return reports