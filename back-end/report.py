from flask import Blueprint, request, jsonify
from config import mysql  

report_bp = Blueprint('auth', __name__)


from flask import Blueprint, request, jsonify
from config import mysql  

report_bp = Blueprint('report', __name__)

@report_bp.route("/efetuar_report", methods=['POST']) 
def efetuar_report():
    dados = request.json
    endereco = dados['endereco']
    categoria = dados['id_categoria']
    duracao = dados['duracao']
    descricao = dados['descricao']
    url_imagem = dados['url_imagem']
    data_report = dados['data_report']
    id_usuario = dados['id_usuario']
    
    try:
        cursor = mysql.connection.cursor()
        cursor.execute("""
            INSERT INTO report (endereco, id_categoria, duracao, descricao, url_imagem, data_report, id_usuario)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (endereco, categoria, duracao, descricao, url_imagem, data_report, id_usuario))
        mysql.connection.commit()
        cursor.close()
        return jsonify({'mensagem': 'Reporte realizado com sucesso!'}), 201
    except Exception as e:
        return jsonify({'erro': str(e)}), 500

@report_bp.route("/listar_reports", methods=['GET'])  
def listar_reports():

    dados = request.json
    id_usuario = dados["id_usuario"];

    try:
        cursor = mysql.connection.cursor()
        cursor.execute("""
        SELECT id_report, endereco, id_categoria, duracao, descricao, url_imagem, data_report, id_usuario FROM report WHERE id_usuario = %s
""", (int(id_usuario),))
        resultados = cursor.fetchall()
        
        reports = []
        for linha in resultados:
            reports.append({
                "id": linha[0],
                "endereco": linha[1],
                "id_categoria": linha[2],
                "duracao": linha[3],
                "descricao": linha[4],
                "url_imagem": linha[5],
                "data_report": linha[6].strftime('%Y-%m-%d %H:%M:%S') if linha[6] else None,
                "id_usuario": linha[7]
            })
    except Exception as e:
        mysql.connection.rollback()
        return jsonify({"erro": "Falha ao buscar relatórios", "detalhes": str(e)}), 500

    return jsonify({"reports": reports}), 200
