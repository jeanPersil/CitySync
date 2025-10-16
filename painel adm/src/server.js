const express = require("express");
const bodyParser = require("body-parser");
const path = require("path");
const userController = require("./controller/user_controller");
const reportsController = require("./controller/reports_controller");

const app = express();
const port = 3000;

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// SERVIR ARQUIVOS ESTÁTICOS
app.use(express.static(path.join(__dirname, "..", "public")));

// SERVIR PÁGINAS
app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "../public/pages/index.html"));
});

app.get("/dashboard", userController.verificarToken, (req, res) => {
  res.sendFile(path.join(__dirname, "../public/pages/dashboard.html"));
});

app.get("/gestao", userController.verificarToken, (req, res) => {
  res.sendFile(path.join(__dirname, "../public/pages/gestao.html"));
});

app.get("/usuario", userController.verificarToken, (req, res) => {
  res.sendFile(path.join(__dirname, "../public/pages/usuario.html"));
});

app.get("/configuracao", userController.verificarToken, (req, res) => {
  res.sendFile(path.join(__dirname, "../public/pages/configuracoes.html"));
});

// ROTAS DE API
app.post("/login", userController.login);
app.post("/verificarToken", userController.verificarToken);
app.get("/reports", reportsController.obterReportesPorPeriodo);
app.get("/reportsFiltrados", reportsController.filtrarReports);

app.put("/editar/:id", reportsController.editarReport);

app.delete("/deletar/:id", reportsController.deletarReport);

app.listen(port, () => {
  console.log(`Servidor rodando na porta http://localhost:${port}`);
});
