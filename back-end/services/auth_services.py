from validate_docbr import CPF
from repositories import auth_repository
import bcrypt

cpf_validator = CPF()

def cadastrar_usuario(dados):
    try:
        cpf = dados['cpf']
        senha = dados['senha']

        if not cpf_validator.validate(cpf):
            return {'erro': 'CPF inválido'}, 400

        usuario_existente = auth_repository.buscar_usuario_por_cpf_ou_email(
            dados['cpf'], dados['email']
        )

        if usuario_existente:
            return {'erro': 'Usuário já cadastrado.'}, 400
        
        senha_bytes = senha.encode('utf-8')
        senha_hash = bcrypt.hashpw(senha_bytes, bcrypt.gensalt())

        id_endereco = auth_repository.inserir_endereco(
            dados['logradouro'],
            dados['numero'],
            dados['bairro'],
            dados['cidade'],
            dados['cep']
        )

        auth_repository.inserir_usuario(
            dados['nome'],
            dados['cpf'],
            dados['email'],
            dados['telefone'],
            senha_hash.decode('utf-8'),
            id_endereco
        )

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
    
   

    

