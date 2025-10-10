const express = require("express");
const bodyParser = require("body-parser");
const path = require("path");
const supabase = require("./config");
const userController = require("./controller/user_controller");
const reportsController = require("./controller/reports_controller");

const app = express();
const port = 3000;

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, "..", "public")));

app.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "../views/index.html"));
});

app.get("/dashboard", (req, res) => {
  res.sendFile(path.join(__dirname, "../views/dashboard.html"));
});

app.get("/gestao", (req, res) => {
  res.sendFile(path.join(__dirname, "../views/gestao.html"));
});

app.get("/usuario", (req, res) => {
  res.sendFile(path.join(__dirname, "../views/usuario.html"));
});

app.get("/configuracao", (req, res) => {
  res.sendFile(path.join(__dirname, "../views/configuracoes.html"));
});

app.post("/login", userController.login);

app.post("/verificarToken", userController.verificarToken);

app.get("/reports", reportsController.obterTodosOsReports);

app.listen(port, () => {
  console.log(`Servidor rodando na porta http://localhost:${port}`);
});
