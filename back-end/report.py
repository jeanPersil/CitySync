#report.py
from flask import Blueprint, request, jsonify
from config import mysql  

report_bp = Blueprint('report', __name__)

@report_bp.route("/efetuar_report", methods=['POST']) 
def efetuar_report():
    dados = request.json
    endereco = dados['endereco']
    categoria = dados['categoria']
    id_usuario = dados['id_usuario']
    duracao = dados['duracao']
    descricao = dados['descricao']
    url_imagem = dados['url_imagem']
    
    try:
        cursor = mysql.connection.cursor()
        cursor.execute("""
            INSERT INTO report (endereco, categoria_id, duracao, descricao, url_imagem, usuario_id)
            VALUES (%s, %s, %s, %s, %s, %s)
        """, (endereco, categoria, duracao, descricao, url_imagem, id_usuario))
        mysql.connection.commit()
        cursor.close()
        return jsonify({
            'status': 'successo',
            'mensagem': 'Reporte realizado com sucesso!'
        }), 201
    except Exception as e:
        return jsonify({'erro': str(e)}), 500

@report_bp.route("/listar_reports", methods=['POST'])  
def listar_reports():
    dados = request.json
    if "id_usuario" not in dados:
        return jsonify({"erro": "Campo 'id_usuario' ausente"}), 400
    id_usuario = dados["id_usuario"]

    try:
        cursor = mysql.connection.cursor()
        cursor.execute("""
            SELECT * FROM listar_problemas WHERE usuario_id = %s
        """, (int(id_usuario),))
        resultados = cursor.fetchall()
        
        reports = []
        for linha in resultados:
            reports.append({
                "id": linha[0],
                "endereco": linha[1],
                "categoria": linha[2],  
                "status": linha[3],     
                "id_usuario": linha[4],
                "duracao": linha[5],
                "url_imagem": linha[6],
                "data_report": linha[7] 
            })
        
    except Exception as e:
        mysql.connection.rollback()
        return jsonify({"erro": "Falha ao buscar relatórios", "detalhes": str(e)}), 500
    finally:
        cursor.close()

    return jsonify({"reports": reports}), 200