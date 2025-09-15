from repositories import auth_repository
from models.usuario_endereco import Usuario


def cadastrar_user(usuario_dados: Usuario):
    try:

        usuario_existente = auth_repository.buscar_usuario_por_cpf_ou_email(usuario_dados)
        
        if usuario_existente:
            return {"erro" : "Usuário já cadastrado com este CPF ou e-mail"}, 401
        
        response = auth_repository.cadastrar_usuario_supa(usuario_dados)
        
        if response:
            return {"mensagem" : "Usuario cadastrado com sucesso!"}, 200
 
    except Exception as e:
        return {'erro': 'Erro ao cadastrar usuário', 'detalhes': str(e)}, 500
    

def realizar_login_supa(email, senha):

     try:
        
        response = auth_repository.login_usuario_supa(email, senha)
        
        return response
 
     except Exception as e:
        return {'erro': 'Erro ao cadastrar usuário', 'detalhes': str(e)}, 500
   

def realizar_login_admin(email, senha):
    try:
        resultado = auth_repository.realizar_login_admin(email, senha)

        if not resultado:
            return {"erro" : "Usuario ou senha invalido"}, 401
        
        if not resultado["tipo_usuario"] == "admin":
            return {"erro" : "Usuario sem acesso!"}, 401
        
        return {"usuario" : {"nome" : resultado["nome"], "tipo_usuario" : resultado["tipo_usuario"] }}, 201

    except Exception as e:
        return {"erro": "Falha interna"}, 500
    
