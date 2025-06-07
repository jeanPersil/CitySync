from flask import Blueprint, request, jsonify
from validate_docbr import CPF
from services import auth_services

auth_bp = Blueprint('auth', __name__)
validador_cpf = CPF()

@auth_bp.route('/cadastrar', methods=['POST'])
def cadastrar_usuario():
    dados = request.json
    resposta, status = auth_services.cadastrar_usuario(dados)
    return jsonify(resposta), status

@auth_bp.route('/login', methods=['POST'])
def login_usuario():
    dados = request.json  
    resultado, status = auth_services.realizar_login(dados)
    return jsonify(resultado), status
   
    
