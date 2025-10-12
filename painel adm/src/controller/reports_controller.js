const supabase = require("../config");
const ReportModel = require("../models/reportModel");

class ReportsController {
  async obterTodosOsReports(req, res) {
    let periodoDeReports = req.query.periodo || 365;

    let dataInicio = new Date();
    let dataFim = new Date();
    dataInicio.setDate(dataFim.getDate() - parseInt(periodoDeReports));

    try {
      const { data, error } = await supabase
        .from("listar_reportes")
        .select("*")
        .gte("data_criacao", dataInicio.toISOString())
        .lte("data_criacao", dataFim.toISOString());

      if (error) {
        return res.status(400).json({ message: error.message });
      }

      console.log("dataInicio:", dataInicio.toISOString());
      console.log("dataFim:", dataFim.toISOString());
      console.log("Total reports:", data.length);

      const reports = data.map((row) => ({
        ...ReportModel.fromDb(row),
      }));

      const problemasResolvidos = reports.filter(
        (r) => r.nome_status === "Resolvido"
      );
      const problemasEmAndamento = reports.filter(
        (r) => r.nome_status === "Em andamento"
      );
      const problemasPendentes = reports.filter(
        (r) => r.nome_status === "Pendente"
      );

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
