from config import init_supabase

supabase = init_supabase()

def inserir_report(endereco, categoria_id, duracao, descricao, url_imagem, usuario_id):
    try:
        response = supabase.table("report").insert({
            "endereco": endereco,
            "categoria_id": categoria_id,
            "duracao": duracao,
            "descricao": descricao,
            "url_imagem": url_imagem,
            "usuario_id": usuario_id
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