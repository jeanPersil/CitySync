const express = require("express");
const router = express.Router();
const reportsController = require("../controller/reports_controller");

// Rotas de leitura
router.get("/periodo", reportsController.obterReportesPorPeriodo);
router.get("/filtrados", reportsController.filtrarReports);

// Rotas de edição e exclusão
router.put("/editar/:id", reportsController.editarReport);
router.delete("/deletar/:id", reportsController.deletarReport);

module.exports = router;
