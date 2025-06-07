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
        "id": linha[0],
        "endereco": linha[1],
        "categoria": linha[2],
        "status": linha[3],
        "id_usuario": linha[4],
        "duracao": linha[5],
        "url_imagem": linha[6],
        "data_report": linha[7]
    } for linha in resultados]
    return reports