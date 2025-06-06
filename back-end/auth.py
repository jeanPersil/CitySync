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
    cep = dados['cep']
    nome_usuario = dados['nome']
    cpf_usuario = dados['cpf']
    email_usuario = dados['email']
    senha_usuario = dados['senha']  
    telefone_usuario = dados['telefone']

    try:
        cursor = mysql.connection.cursor()

        cursor.execute("SELECT id_usuario FROM usuario WHERE cpf = %s OR email = %s", (cpf_usuario, email_usuario))
        if cursor.fetchone():
            return jsonify({'erro': 'Usuário já cadastrado.'}), 400

        cursor.execute("""
            INSERT INTO endereco (logradouro, numero, bairro, fk_cidade, cep)
            VALUES (%s, %s, %s, %s, %s)
        """, (logradouro, numero_casa, bairro, cidade, cep))
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
def login_usuario():
    dados = request.json
    email = dados.get('email')
    senha = dados.get('senha')

    try:
        cursor = mysql.connection.cursor()

        cursor.execute("SELECT id_usuario, nome, senha FROM usuario WHERE email = %s", (email,))
        usuario = cursor.fetchone()

        if not usuario:
            return jsonify({'erro': 'Usuário não encontrado.'}), 404

        id_usuario, nome, senha_banco = usuario

        if senha != senha_banco:
            return jsonify({'erro': 'Senha incorreta.',
                            'senha recebida': senha,
                            'senha banco': senha_banco}), 401

        return jsonify({
            'mensagem': 'Login realizado com sucesso!',
            'usuario': {
                'id': id_usuario,
                'nome': nome,
            }
        }), 200

    except Exception as e:
        return jsonify({'erro': str(e)}), 500
