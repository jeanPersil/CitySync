from flask import Blueprint, request, jsonify
from services import report_services
from models.report import Report

report_bp = Blueprint('report', __name__)

@report_bp.route("/efetuar_report", methods=['POST']) 
def efetuar_report():
    dados = request.json

    if not dados:
        return jsonify({"erro", "Dados não enviados"}), 400

    report = Report(
        None,
        dados['endereco'],
        dados['categoria'],
        None,
        dados['id_usuario'],
        dados['duracao'],
        dados['descricao'],
        dados['url_imagem'],
    )

    if not report.verificar_campos_obrigatorios():
        return jsonify ({'erro' : 'Dados do report incompletos'}), 400

    try:
        report_services.efetuar_report(report)
        return jsonify({'status': 'successo', 'mensagem': 'Reporte realizado com #sucesso!'}), 201 
 
    except Exception as e:
        return jsonify({'erro': str(e)}), 500

@report_bp.route("/listar_reports/<int:id_usuario>", methods=['GET'])  
def listar_reports(id_usuario):
    if id_usuario <= 0:
        return jsonify({"erro": "Nenhum usuario encontrado"}), 400
    try:
        reports = report_services.listar_reports_do_usuario(id_usuario)
        return jsonify({"reports": reports}), 200
    except Exception as e:
        return jsonify({"erro": "Falha ao buscar relatórios", "detalhes": str(e)}), 500



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
    


