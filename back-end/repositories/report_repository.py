from config import init_supabase
from models.usuario_endereço import Report
supabase = init_supabase()

def inserir_report(report : Report):
    try:
        response = supabase.table("report").insert({
            "endereco": report.endereco,
            "categoria_id": report.categoria_id,
            "duracao": report.duracao,
            "descricao": report.descricao,
            "url_imagem": report.url_imagem,
            "usuario_id": report.usuario_id
        }).execute()
        return True if response.data else False
    except Exception as e:
        raise e

def buscar_reports_por_usuario(usuario_id):
    try:
        response = supabase.rpc("listar_problemas_por_usuario", {"u_id": usuario_id}).execute()
        return response.data
    except Exception as e:
        raise e