from flask import Blueprint, request, jsonify
from services import auth_services
from models.usuario_endereco import Usuario

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/cadastrar', methods=['POST'])
def cadastrar_usuario():
    dados = request.json

    usuario = Usuario(
        None, 
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
    
    
    resposta, status = auth_services.cadastrar_usuario(usuario)
    return jsonify(resposta), status


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
    
   
   
    
