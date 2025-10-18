/**
 * ROUTES - Camada de definição de rotas e middlewares
 *
 * Responsabilidades:
 * - Definir endpoints da aplicação e seus métodos HTTP
 * - Aplicar middlewares de autenticação/autorização
 * - Servir arquivos estáticos (HTML, CSS, JS)
 * - Mapear URLs para controllers/actions específicos
 * - Gerenciar proteção de rotas com verificações de acesso
 *
 * NÃO contém lógica de negócio (service)
 * NÃO processa requisições diretamente (controller)
 */

const express = require("express");
const router = express.Router();
const userController = require("../controller/user_controller");

router.post("/login", userController.login);
router.post("/verificarToken", userController.verificarToken);
router.post("/logout", userController.logout);
router.post("/esqueceuSenha", userController.solicitar_recuperacao_senha);

module.exports = router;
