const supabase = require("../config");

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
        .select("role")
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

      return res.status(200).json({
        success: true,
        data: data.user,
        redirect: "/dashboard",
        token: data.session.access_token,
      });
    } catch (error) {
      console.error("Erro no login:", error);
      return res.status(500).json({
        success: false,
        message: "Erro interno do servidor.",
      });
    }
  }

  async verificarToken(req, res) {
    try {
      const token = req.headers["authorization"]?.replace("Bearer ", "");

      if (!token) {
        return res.status(401).json({ message: "Token não fornecido" });
      }

      const { data, error } = await supabase.auth.getUser(token);

      if (error || !data.user) {
        return res.status(401).json({ message: "Token inválido ou expirado" });
      }

      return res.status(200).json({
        success: true,
        redirect: "/dashboard",
        user: data.user,
      });
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: `erro: ${error.messsage}`,
      });
    }
  }
}
module.exports = new UserController();
