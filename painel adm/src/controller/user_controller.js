const supabase = require("../config");
const { validarEmailBasico } = require("../utils/utils")

class UserController {
  async login(req, res) {
    try {
      const { email, senha } = req.body;

      if (!email?.trim() || !senha?.trim()) {
        return res.status(400).json({
          success: false,
          message: "Preencha todos os campos obrigatórios.",
        });
      }

      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password: senha,
      });

      if (error) {
        return res.status(401).json({
          success: false,
          message: error.message,
        });
      }

      const { data: dataUser, error: errorUser } = await supabase
        .from("users")
        .select("role, nome, email")
        .eq("id", data.user.id)
        .single();

      if (errorUser) {
        return res.status(401).json({
          success: false,
          message: errorUser.message,
        });
      }

      if (dataUser.role !== "admin") {
        return res.status(403).json({
          success: false,
          message: "Acesso negado. Usuário não é admin.",
        });
      }

      // Após passar pelas validações

      const accessToken = data.session.access_token;

      res.cookie("authToken", accessToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        maxAge: 3600000,
        sameSIte: "strict",
      });

      return res.status(200).json({
        success: true,
        user: {
          role: dataUser.role,
          nome: dataUser.nome,
          email: dataUser.email,
        },
        redirect: "/dashboard",
      });
    } catch (error) {
      console.error("Erro no login:", error);
      return res.status(500).json({
        success: false,
        message: "Erro interno do servidor.",
      });
    }
  }

  async logout(req, res) {
    try {
      res.clearCookie("authToken", {
        httpOnly: true,
        secure: process.env.NODE_ENV === "production",
        sameSite: "strict",
      });

      return res.status(200).json({
        success: true,
        redirect: "/",
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: "erro no servidor",
      });
    }
  }


  async recuperarSenha(req, res){
    const email = req.body;

    if(!email){
      return res.status(400).json({
        success: false,
        message: "É obrigatorio inserir um e-mail."
      })
    }

    if(!validarEmailBasico(email)){
      return res.status(400).json({
        success: false,
        message: "O e-mail inserido é invalido"
      })
    }

    const {data, error} = await supabase.auth.resend({
      type: recovery,
      email: email, 
      
    })






  }
  

  async verificarToken(req, res, next) {
    try {
      const token = req.cookies.authToken;

      if (!token) {
        return res.redirect("/");
      }

      const { data, error } = await supabase.auth.getUser(token);

      if (error || !data.user) {
        res.clearCookie("authToken");
        return res.redirect("/");
      }

      next();
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: `erro no token: ${error}`,
      });
    }
  }
}
module.exports = new UserController();
