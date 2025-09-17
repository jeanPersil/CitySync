from flask import Blueprint, request, jsonify
from services import report_services
from models.report import Report

report_bp = Blueprint('report', __name__)


@report_bp.route("/efetuar_report_supa", methods=['POST'])
def efetuar_report_supa():
    dados = request.json
    required_fields = ['endereco', 'categoria', 'id_usuario', 'descricao']

    if not dados or not all(field in dados and dados[field] for field in required_fields):
        return jsonify({"erro": "Dados incompletos"}), 400

    endereco = dados['endereco']
    categoria = dados['categoria']
    id_usuario = dados['id_usuario']
    descricao = dados['descricao']
    url_imagem = dados['url_imagem']

    response, status = report_services.efetuar_report_supa(endereco, categoria, id_usuario, descricao, url_imagem)
    return jsonify(response), status



@report_bp.route("/listar_reports_app/<string:id_usuario>", methods=['GET'])  
def listar_reports(id_usuario):
    try:
        reports = report_services.listar_reports_do_usuario(id_usuario)
        return jsonify({"reports": reports}), 200
    except Exception as e:
        return jsonify({"erro": "Falha ao buscar relatórios", "detalhes": str(e)}), 500



@report_bp.route("/editar_report", methods=['POST'])
def editar_report():
    dados = request.json
    id_report = dados["id_report"]
    status_id = dados["status_id"]

    try:
        resposta, status = report_services.editar_report(id_report, status_id)
        return jsonify(resposta), status
    except Exception as e:
        return jsonify({'erro': str(e)}), 500



@report_bp.route("/listar_reports_admin", methods=['POST'])
def listar_reports_admin():
    try:
        dados = request.json
        
        bairro = dados['bairro']
        status = dados['status']
        categoria = dados['categoria']
        data = dados['data']

        
        reports = report_services.listar_reports_admin(bairro, status, data, categoria)
        return jsonify({"lista": reports})  
    except Exception as e:
        return jsonify({"error": str(e)}), 500  
    

@report_bp.route("/deletar_report", methods=["POST"])
def deletar_report():
    try:
        dados = request.json
        id_report = dados["id_report"]
        
        resposta, status = report_services.deletar_report(id_report)

        return jsonify(resposta), status

    except Exception as e:
        return jsonify({"error": str(e)}), 500  
    


