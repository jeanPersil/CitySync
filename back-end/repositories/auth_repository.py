from config import init_supabase
from models.usuario_endereço import Endereco, Usuario
import bcrypt


supabase = init_supabase()

def buscar_usuario_por_cpf_ou_email(usuario_dados : Usuario):
    response = supabase.table("usuario").select("id_usuario").or_(f"cpf.eq.{usuario_dados.cpf},email.eq.{usuario_dados.email}").execute()
    data = response.data
    return data[0] if data else None

def inserir_endereco(endereco_usuario : Endereco):
    response = supabase.table("endereco").insert({
        "logradouro": endereco_usuario.logradouro,
        "numero": endereco_usuario.numero,
        "bairro": endereco_usuario.bairro,
        "fk_cidade": endereco_usuario.id_cidade,
        "cep": endereco_usuario.cep
    }).execute()
    data = response.data
    return data[0]["id_endereco"] if data else None


def inserir_usuario( usuario_dados : Usuario, senha, id_endereco,):
    response = supabase.table("usuario").insert({
        "nome": usuario_dados.nome,
        "cpf": usuario_dados.cpf,
        "email": usuario_dados.email,
        "telefone": usuario_dados.telefone,
        "senha": senha,
        "id_endereco": id_endereco
    }).execute()
    return response.data
    
def realizar_login(email, senha_digitada):
    response = supabase.table("usuario").select("id_usuario, nome, senha").eq("email", email).execute()
    usuario = response.data
    if not usuario:
        return None
    usuario = usuario[0]
    if bcrypt.checkpw(senha_digitada.encode('utf-8'), usuario["senha"].encode('utf-8')):
        return {"id_usuario": usuario["id_usuario"], "nome": usuario["nome"]}
    else:
        return None

def realizar_login_admin(email, senha):
    try:
        response = supabase.table("usuario").select("nome, senha, tipo_usuario").eq("email", email).execute()
        
        if not response.data:
            return None 

        usuario = response.data[0]  
        
        if bcrypt.checkpw(senha.encode('utf-8'), usuario["senha"].encode('utf-8')):
            return {
                "nome": usuario["nome"],
                "tipo_usuario": usuario["tipo_usuario"]
            }
        
        return None
  

    except Exception as e:
        return {"erro": str(e)}, 500
