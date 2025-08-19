from config import init_supabase
from models.report import Report
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
         return {"erro" : "falha ao reportar o problema", 'detalhes' : str(e)}
    

def editar_status_report(report_id, status_id):
    try:
        response = supabase.table("report").update({"status_id": status_id}).eq("id", report_id).execute()
        return True if response.data else False
    except Exception as e:
         return {"erro" : "falha ao editar o status do problema", 'detalhes' : str(e)} 

def buscar_reports_por_usuario(usuario_id):
    try:
        response = supabase.rpc("listar_problemas_por_usuario", {"u_id": usuario_id}).execute()
        return response.data
    except Exception as e:
         return {"erro" : "falha ao buscar reports", 'detalhes' : str(e)}
    
def buscar_todos_reports(bairro = None, status= None, data=None, categoria=None):
    try:
        query = supabase.table("view_reports_completos").select("*")
    
        if bairro:
            query = query.ilike("local_problema", bairro)
            
        if status:
            query = query.eq("status", status)
        
        if categoria:
            query = query.eq("categoria", categoria)
        
        if data:
            query = query.gte("data_criacao_formatada", data)

        respose = query.execute()

        if respose.data:
            return respose.data
        else:
            return []
        
        
    except Exception as e:
        return {"erro" : "falha ao buscar reports", 'detalhes' : str(e)}
