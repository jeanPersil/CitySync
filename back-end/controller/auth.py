from flask import Blueprint, request, jsonify
from services import auth_services
from repositories import auth_repository
from models.usuario_endereco import Usuario

auth_bp = Blueprint('auth', __name__)


@auth_bp.route('/cadastrar_user', methods=['POST'])
def cadastrar_user():
    dados = request.json
    usuario = Usuario(
        dados['nome'],
        dados['cpf'],
        dados['email'],
        dados['telefone'],
        dados['senha'],
        dados['cep'],
        dados['fk_cidade'],
    )

    if not usuario.verificar_campos_obrigatorios():
        return jsonify ({'erro' : 'Dados de cadastro incompletos'}), 401
    
    if not usuario.validar_cpf_usuario():
        return jsonify({'erro': 'CPF inválido'}), 401
    
    if not usuario.validar_cep():
        return jsonify({"erro" : "CEP invalido"}), 401
    
    resposta = auth_services.cadastrar_user(usuario)
    return jsonify(resposta)


@auth_bp.route('/login_user', methods=["POST"])
def login_user():
    dados = request.json

    email = dados['email']
    senha = dados['senha']

    response = auth_repository.login_usuario_supa(email, senha)

    return jsonify(response)


@auth_bp.route('/login', methods=['POST'])
def login_usuario():
    dados = request.json  
    resultado, status = auth_services.realizar_login(dados)
    return jsonify(resultado), status


@auth_bp.route("/login_admin", methods=['POST'])
def login_admin():
    dados = request.json
    email = dados["email"]
    senha = dados["senha"]

    if email == "" or senha == "":
        return jsonify({"erro" : "Os campos não foram preenchdios"})
    
    resultado, status = auth_services.realizar_login_admin(email, senha)
    return jsonify(resultado), status


@auth_bp.route("/esqueceu_senha", methods=['POST'])
def esqueceu_senha():
    dados = request.json

    email = dados['email']

    resultado = auth_services.esqueceu_senha(email)
    return jsonify(resultado)
    
   
   
    
