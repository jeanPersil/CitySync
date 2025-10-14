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
        total: reports.length,
      });
    } catch (error) {
      console.error("Erro ao obter reports:", error);
    }
  }

  async filtrarReports(req, res) {
    const { endereco, data, status, pesquisar, categoria } = req.query;

    try {
      let query = supabase.from("listar_reportes").select("*");

      if (endereco) {
        query = query.ilike("endereco", `%${endereco}%`);
      }

      if (status) {
        query = query.eq("nome_status", status);
      }

      if (categoria) {
        query = query.eq("nome_categoria", categoria);
      }

      if (data) {
        const inicio = new Date(data);
        const fim = new Date(data);
        fim.setDate(fim.getDate() + 1);

        query = query
          .gte("data_criacao", inicio.toISOString())
          .lt("data_criacao", fim.toISOString());
      }

      if (pesquisar) {
        const termo = `%${pesquisar}%`;
        query = query.or(
          `descricao.ilike.${termo},endereco.ilike.${termo},nome_categoria.ilike.${termo}`
        );
      }

      const { data: reportsData, error } = await query;

      if (error) {
        console.error("Erro Supabase:", error.message);
        return res.status(400).json({ success: false, message: error.message });
      }

      const reports = reportsData.map((row) => ({
        ...ReportModel.fromDb(row),
      }));

      return res.status(200).json({
        success: true,
        total: reports?.length || 0,
        reports,
      });
    } catch (error) {
      console.error("Erro interno:", error);
      return res.status(500).json({
        success: false,
        message: "Erro interno no servidor",
      });
    }
  }
}

module.exports = new ReportsController();
