const express = require("express");
const router = express.Router();
const userController = require("../controller/user_controller");

router.post("/login", userController.login);
router.post("/verificarToken", userController.verificarToken);
router.post("/logout", userController.logout);

module.exports = router;
