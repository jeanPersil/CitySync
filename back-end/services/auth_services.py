from repositories import auth_repository
from models.usuario_endereço import Endereco, Usuario
import bcrypt


def cadastrar_usuario(usuario : Usuario, endereco : Endereco):
    try:
        
        usuario_existente = auth_repository.buscar_usuario_por_cpf_ou_email(usuario)
        if usuario_existente:
            return {'erro': 'Usuário já cadastrado.'}, 400
        
        #criptografando a senha
        senha = usuario.senha
        senha_bytes = senha.encode('utf-8')
        senha_hash = bcrypt.hashpw(senha_bytes, bcrypt.gensalt())

        # inserindo o endereço no banco de dados
        id_endereco = auth_repository.inserir_endereco(endereco)

        #cadastrando usuario no banco com senha criptografada + id de endereço
        auth_repository.inserir_usuario(usuario, senha_hash.decode('utf-8'), id_endereco)

        return {'mensagem': 'Usuário cadastrado com sucesso!'}, 200

    except Exception as e:
        return {'erro': 'Erro ao cadastrar usuário', 'detalhes': str(e)}, 500


def realizar_login(dados):

    try:
        resultado = auth_repository.realizar_login(dados['email'], dados['senha'])
        if resultado:
            return {"usuario" : {"id": resultado["id_usuario"], "nome": resultado["nome"]}}, 200
        else:
            return{"erro": "Usuário ou senha inválido."}, 401

    except Exception as e:
        return {'erro': str(e)}, 500


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

