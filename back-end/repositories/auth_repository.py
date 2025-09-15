from config import init_supabase
from models.usuario_endereco import  Usuario
import bcrypt


supabase = init_supabase()

def buscar_usuario_por_cpf_ou_email(usuario_dados : Usuario):
   try:
    response = supabase.table("users").select("id").or_(f"cpf.eq.{usuario_dados.cpf},email.eq.{usuario_dados.email}").execute()
    data = response.data
    return data[0] if data else None
    
   except Exception as e:
       return {"erro" : str(e)}


def cadastrar_usuario_supa(usuario_dados : Usuario):
    try:
        response = supabase.auth.sign_up({
            "email": usuario_dados.email,
            "password": usuario_dados.senha
        })

        user = response.user

        supabase.table("users").insert({
        "id": user.id,
        "nome": usuario_dados.nome,
        "email": usuario_dados.email,
        "cpf": usuario_dados.cpf,
        "telefone": usuario_dados.telefone,
        "cep": usuario_dados.cep,
        "fk_cidade" : usuario_dados.fk_cidade,
        "role": "usuario"
        }).execute()

        return True


    except Exception as e:
        return {"erro x": str(e)}, 


def login_usuario_supa(email: str, senha: str):
    try:
        response = supabase.auth.sign_in_with_password({
            "email": email,
            "password": senha
        })

        if response.user:
            nome_user = supabase.table("users").select("nome").eq("id", response.user.id).execute()
            data = nome_user.data
            nome = data[0]["nome"]

            return {"user_id": response.user.id, "nome_usuario" : nome}
        return False
    except Exception as e:
        if "Invalid login credentials" in str(e):
            return {"erro": "Usuário ou senha incorretos"}, 401        
        
        return {"erro": str(e)}, 500


def inserir_usuario( usuario_dados : Usuario, senha, ):
    response = supabase.table("usuario").insert({
        "nome": usuario_dados.nome,
        "cpf": usuario_dados.cpf,
        "email": usuario_dados.email,
        "telefone": usuario_dados.telefone,
        "senha": senha,
        "cep" : usuario_dados.cep,
        "fk_cidade" : usuario_dados.fk_cidade
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
        
def esqueci_senha_supa(email):
    
    response = supabase.table("users").select("id").eq("email", email).execute()

    if not response.data:
        return {"erro" : "Usuario não cadastrado"}, 404
    try:
        supabase.auth.reset_password_for_email(email=email)
        return {"mensagem" : "E-mail de redefinição enviado com sucesso!"}
    except Exception as e:
        return {"erro" : str(e)}