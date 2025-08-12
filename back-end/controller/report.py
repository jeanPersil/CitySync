from flask import Blueprint, request, jsonify
from services import report_services
from models.usuario_endereço import Report

report_bp = Blueprint('report', __name__)

@report_bp.route("/efetuar_report", methods=['POST']) 
def efetuar_report():
    dados = request.json

    report = Report(
        
    )
    try:
        report_services.efetuar_report(dados)
        return jsonify({'status': 'successo', 'mensagem': 'Reporte realizado com sucesso!'}), 201
    except Exception as e:
        return jsonify({'erro': str(e)}), 500

@report_bp.route("/listar_reports/<int:id_usuario>", methods=['GET'])  
def listar_reports(id_usuario):
    try:
        reports = report_services.listar_reports(id_usuario)
        return jsonify({"reports": reports}), 200
    except Exception as e:
        return jsonify({"erro": "Falha ao buscar relatórios", "detalhes": str(e)}), 500
