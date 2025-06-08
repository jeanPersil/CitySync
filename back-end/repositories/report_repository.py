from config import mysql

def inserir_report(endereco, categoria_id, duracao, descricao, url_imagem, usuario_id):
    try:
        cursor = mysql.connection.cursor()
        cursor.execute("""
            INSERT INTO report (endereco, categoria_id, duracao, descricao, url_imagem, usuario_id)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (endereco, categoria_id, duracao, descricao, url_imagem, usuario_id))
        mysql.connection.commit()
        return True
    except Exception as e:
        mysql.connection.rollback()
        raise e
    finally:
        cursor.close()

def buscar_reports_por_usuario(usuario_id):
    try:
        cursor = mysql.connection.cursor()
        cursor.execute("""
            SELECT * FROM listar_problemas WHERE usuario_id = %s
        """, (int(usuario_id),))
        resultados = cursor.fetchall()
        return resultados
    except Exception as e:
        raise e
    finally:
        cursor.close()