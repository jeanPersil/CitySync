/**
 * APP CONFIGURATION - Configuração principal do servidor Express
 *
 * Responsabilidades:
 * - Inicializar e configurar o servidor Express
 * - Registrar middlewares globais da aplicação
 * - Definir estrutura de rotas e namespaces
 * - Configurar servidor de arquivos estáticos
 * - Estabelecer pipeline de processamento de requisições
 *
 * Ponto de entrada da aplicação backend
 */

const express = require("express");
const bodyParser = require("body-parser");
const path = require("path");
const cookieParser = require("cookie-parser");

// Importar rotas
const pageRoutes = require("./routes/pageRoutes");
const userRoutes = require("./routes/userRoutes");
const reportRoutes = require("./routes/reportRoutes");

const app = express();

// Middlewares
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cookieParser());

// Arquivos estáticos
app.use(express.static(path.join(__dirname, "../public")));

// Rotas
app.use("/", pageRoutes);
app.use("/api/users", userRoutes);
app.use("/api/reports", reportRoutes);

module.exports = app;
