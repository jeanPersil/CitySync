from flask import Blueprint, request, jsonify
from validate_docbr import CPF
from services import auth_services
from models.usuario_endereço import Endereco, Usuario

auth_bp = Blueprint('auth', __name__)
validador_cpf = CPF()

@auth_bp.route('/cadastrar', methods=['POST'])
def cadastrar_usuario():
    dados = request.json

    endereco = Endereco(
        None,
        dados ['logradouro'],
        dados['numero'],
        dados['bairro'],
        dados['cep'],
        dados['cidade'],
    )
    usuario = Usuario(
        None, 
        dados['nome'],
        dados['cpf'],
        dados['email'],
        dados['telefone'],
        dados['senha'],
        None
    )

    resposta, status = auth_services.cadastrar_usuario(usuario, endereco)
    return jsonify(resposta), status


@auth_bp.route('/login', methods=['POST'])
def login_usuario():
    dados = request.json  
    resultado, status = auth_services.realizar_login(dados)
    return jsonify(resultado), status
   
    
