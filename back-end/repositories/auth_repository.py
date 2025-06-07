from config import mysql

def buscar_usuario_por_cpf_ou_email(cpf, email):
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT id_usuario FROM usuario WHERE cpf = %s OR email = %s", (cpf, email))
    resultado = cursor.fetchone()
    cursor.close()
    return resultado

def inserir_endereco(logradouro, numero, bairro, cidade, cep):
    cursor = mysql.connection.cursor()
    cursor.execute("""
        INSERT INTO endereco (logradouro, numero, bairro, fk_cidade, cep)
        VALUES (%s, %s, %s, %s, %s)
    """, (logradouro, numero, bairro, cidade, cep))
    mysql.connection.commit()
    id_endereco = cursor.lastrowid
    cursor.close()
    return id_endereco

def inserir_usuario(nome, cpf, email, telefone, senha, id_endereco):
    cursor = mysql.connection.cursor()
    cursor.execute("""
        INSERT INTO usuario (nome, cpf, email, telefone, senha, id_endereco)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (nome, cpf, email, telefone, senha, id_endereco))
    mysql.connection.commit()
    cursor.close()

def realizar_login(email, senha_digitada):
    cursor = mysql.connection.cursor()
    cursor.execute("SELECT id_usuario, nome, senha FROM usuario WHERE email = %s", (email,))
    usuario = cursor.fetchone()
    cursor.close()

    if usuario is None:
        return None

    id_usuario, nome, senha_armazenada = usuario

    if senha_digitada == senha_armazenada:
        return {"id_usuario": id_usuario, "nome": nome}
    else:
        return None
