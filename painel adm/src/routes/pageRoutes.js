const express = require("express");
const path = require("path");
const router = express.Router();
const userController = require("../controller/user_controller");

router.get("/", (req, res) => {
  res.sendFile(path.join(__dirname, "../public/pages/index.html"));
});

router.get("/dashboard", userController.verificarToken, (req, res) => {
  res.sendFile(path.join(__dirname, "../public/pages/dashboard.html"));
});

router.get("/gestao", userController.verificarToken, (req, res) => {
  res.sendFile(path.join(__dirname, "../public/pages/gestao.html"));
});

router.get("/usuario", userController.verificarToken, (req, res) => {
  res.sendFile(path.join(__dirname, "../public/pages/usuario.html"));
});

router.get("/configuracao", userController.verificarToken, (req, res) => {
  res.sendFile(path.join(__dirname, "../public/pages/configuracoes.html"));
});

module.exports = router;
