from repositories import report_repository
from models.report import Report

def efetuar_report(report : Report):
    try:
       return report_repository.inserir_report(report)
    except Exception as e:
       return ({'erro' : 'Falha ao reportar', 'detalhes' : str(e)})
    

def editar_report(report_id, novo_status):
    try:
        resultado = report_repository.editar_status_report(report_id, novo_status)

        if not resultado:
            return {"erro": "Report não encontrado ou não atualizado"}, 404
                
        return {"status": "sucesso"}, 200

    except Exception as e:
        return {'erro': 'Falha ao editar report', 'detalhes': str(e)}, 500

def listar_reports_do_usuario(id_usuario):
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


def listar_reports_admin(bairro, status, data, categoria):
   try: 
    reports = report_repository.buscar_todos_reports(bairro=bairro, status=status, data=data, categoria=categoria)
    return reports
   except Exception as e:
      return ({'erro' : 'Falha ao buscar reports', 'detalhes' : str(e)})
   


def deletar_report(id_report):
    try:
        resultado = report_repository.deletar_report(id_report)

        if resultado is True:
            return {"status": "sucesso"}, 200
        elif isinstance(resultado, dict) and "erro" in resultado:
            return resultado, 404  
        else:
            return {"erro": "Erro desconhecido ao deletar o report"}, 500
    except Exception as e:
        return {"erro": "Falha ao apagar o report", "detalhes": str(e)}, 500