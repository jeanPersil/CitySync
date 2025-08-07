from config import mysql
from config import init_supabase
import bcrypt


supabase = init_supabase()

def buscar_usuario_por_cpf_ou_email(cpf, email):
    response = supabase.table("usuario").select("id_usuario").or_(f"cpf.eq.{cpf},email.eq.{email}").execute()
    data = response.data
    return data[0] if data else None

def inserir_endereco(logradouro, numero, bairro, cidade, cep):
    response = supabase.table("endereco").insert({
        "logradouro": logradouro,
        "numero": numero,
        "bairro": bairro,
        "fk_cidade": cidade,
        "cep": cep
    }).execute()
    data = response.data
    return data[0]["id_endereco"] if data else None


def inserir_usuario(nome, cpf, email, telefone, senha, id_endereco):
    response = supabase.table("usuario").insert({
        "nome": nome,
        "cpf": cpf,
        "email": email,
        "telefone": telefone,
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