from flask import Blueprint, request, jsonify
from config import mysql  

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/cadastrar', methods=['POST'])
def cadastrar_usuario():
    dados = request.json
    logradouro = dados['logradouro']
    numero_casa = dados['numero_casa']
    bairro = dados['bairro']
    cidade = dados['cidade']
    estado = dados['estado']
    cep = dados['cep']
    nome_usuario = dados['nome']
    cpf_usuario = dados['cpf']
    email_usuario = dados['email']
    senha_usuario = dados['senha']
    telefone_usuario = dados['telefone']

    try:
        cursor = mysql.connection.cursor()
        cursor.execute("""
            INSERT INTO endereco (logradouro, numero_casa, bairro, cidade, estado, cep)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (logradouro, numero_casa, bairro, cidade, estado, cep))
        mysql.connection.commit()
        id_endereco = cursor.lastrowid

        cursor.execute("""
            INSERT INTO usuario (nome, cpf, email, telefone, senha, id_endereco)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (nome_usuario, cpf_usuario, email_usuario, telefone_usuario, senha_usuario, id_endereco))
        mysql.connection.commit()
        cursor.close()
        return jsonify({'mensagem': 'Usuário cadastrado com sucesso!'}), 201

    except Exception as e:
        return jsonify({'erro': str(e)}), 500

@auth_bp.route('/login', methods=['POST']) 
def logar_usuario():
    dados = request.json
    usuario = dados['usuario']
    senha = dados['senha']

    try:
        cursor = mysql.connection.cursor()
        cursor.execute("""
            SELECT * FROM usuario WHERE email = %s AND senha = %s
        """, (usuario, senha))
        resultado = cursor.fetchone()
        cursor.close()

        if resultado:
            return jsonify({'mensagem': 'Login bem-sucedido!'}), 200
        else:
            return jsonify({'erro': 'Usuário ou senha inválidos'}), 401

    except Exception as e:
        return jsonify({'erro': str(e)}), 500
