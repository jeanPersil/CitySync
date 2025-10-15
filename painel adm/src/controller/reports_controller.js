const supabase = require("../config");
const ReportModel = require("../models/reportModel");
const { mapearCategoria, mapearStatus } = require("../utils/utils");

class ReportsController {
  async obterReportesPorPeriodo(req, res) {
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
      res.status(500).json({
        success: false,
        message: "Erro interno do servidor",
      });
    }
  }

  async filtrarReports(req, res) {
    const { endereco, data, status, pesquisar, categoria } = req.query;

    console.log("🟢 Filtros recebidos:", req.query);

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

  async editarReport(req, res) {
    try {
      const { id } = req.params; // Melhor usar params para ID
      const { endereco, descricao, categoria, status, url_imagem } = req.body;

      // ========== VALIDAÇÕES ==========

      // Validar ID
      if (!id || isNaN(parseInt(id))) {
        return res.status(400).json({
          success: false,
          message: "ID do report é obrigatório e deve ser um número válido",
        });
      }

      // Validar campos obrigatórios
      const camposObrigatorios = {
        endereco,
        descricao,
        categoria,
        status,
      };
      const camposFaltantes = Object.keys(camposObrigatorios).filter(
        (campo) =>
          !camposObrigatorios[campo] ||
          camposObrigatorios[campo].toString().trim() === ""
      );

      if (camposFaltantes.length > 0) {
        return res.status(400).json({
          success: false,
          message: `Campos obrigatórios faltando: ${camposFaltantes.join(
            ", "
          )}`,
        });
      }

      // Validar status permitidos
      const statusPermitidos = ["Pendente", "Em andamento", "Resolvido"];
      if (!statusPermitidos.includes(status)) {
        return res.status(400).json({
          success: false,
          message: `Status inválido. Permitidos: ${statusPermitidos.join(
            ", "
          )}`,
        });
      }

      // ========== PREPARAR DADOS ==========

      const dadosAtualizados = {
        endereco: endereco.trim(),
        descricao: descricao.trim(),
        fk_categoria: mapearCategoria(categoria),
        fk_status: mapearStatus(status),
      };

      // ========== EXECUTAR ATUALIZAÇÃO ==========

      console.log(`📝 Tentando atualizar report ${id}:`, dadosAtualizados);

      const { data, error } = await supabase
        .from("reportes")
        .update(dadosAtualizados)
        .eq("id", parseInt(id))
        .select() // Retornar os dados atualizados
        .single();

      if (error) {
        console.error("❌ Erro Supabase:", error);
        return res.status(400).json({
          success: false,
          message: `Erro ao atualizar report: ${error.message}`,
          details: error.details || null,
        });
      }

      if (!data) {
        return res.status(404).json({
          success: false,
          message: "Report não encontrado ou nenhuma alteração foi feita",
        });
      }

      console.log("✅ Report atualizado com sucesso:", data);

      // ========== RESPOSTA DE SUCESSO ==========

      return res.status(200).json({
        success: true,
        message: "Report atualizado com sucesso",
        data: data,
      });
    } catch (error) {
      console.error("💥 Erro interno no servidor:", error);
      return res.status(500).json({
        success: false,
        message: "Erro interno do servidor ao editar report",
        error:
          process.env.NODE_ENV === "development" ? error.message : undefined,
      });
    }
  }
}

module.exports = new ReportsController();
