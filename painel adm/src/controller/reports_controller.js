const supabase = require("../config");
const ReportModel = require("../models/reportModel");

class ReportsController {
  async obterTodosOsReports(req, res) {
    let problemasResolvidos = [];
    let problemasEmAndamento = [];
    let problemasPendentes = [];

    try {
      const { data, error } = await supabase
        .from("listar_reportes")
        .select("*");
      if (error) {
        return res.status(400).json({ message: error.message });
      }

      const reports = data.map((row) => ({
        ...ReportModel.fromDb(row),
      }));

      reports.forEach((report) => {
        switch (report.nome_status) {
          case "Resolvido":
            problemasResolvidos.push(report);
            break;
          case "Em andamento":
            problemasEmAndamento.push(report);
            break;
          case "Pendente":
            problemasPendentes.push(report);
            break;
          default:
            break;
        }
      });

      return res.status(200).json({
        success: true,
        problemasResolvidos,
        problemasEmAndamento,
        problemasPendentes,
      });
    } catch (error) {
      console.error("Erro ao obter reports:", error);
    }
  }
}

module.exports = new ReportsController();
