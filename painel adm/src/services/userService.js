/**
 * SERVICE - Camada de regras de negócio para usuarios
 *
 * Responsabilidades:
 * - Implementar lógica de negócio e regras de aplicação
 * - Orquestrar operações entre diferentes repositórios
 * - Validar regras específicas do domínio
 * - Tratar autenticação e autorização
 * - Gerenciar fluxos complexos de operações
 *
 * NÃO lida diretamente com HTTP (isso fica no controller)
 * NÃO acessa o banco diretamente (isso fica no repository)
 */

const supabase = require("../config");
const UserRepositories = require("../repositories/userRepositorie"); //

class UserService {
  async autenticarAdmin(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) throw new Error(error.message);

    const dados_usuario = await UserRepositories.pegarDadosPeloId(data.user.id);

    if (!dados_usuario) {
      throw new Error("Detalhes do usuário não encontrados após o login.");
    }

    return {
      session: data.session,
      user: dados_usuario,
    };
  }

  async enviar_email_de_recuperacao_de_senha(email) {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: "https://meusite.com/reset-password",
    });

    if (error) throw new Error(error.message);

    return true;
  }

  async mudarSenha(email, token, novaSenha) {
    const { error: verifyError } = await supabase.auth.verifyOtp({
      email,
      token,
      type: "recovery",
    });

    if (verifyError) throw new Error("Token inválido ou expirado.");

    const { error: updateError } = await supabase.auth.updateUser({
      password: novaSenha,
    });

    if (updateError) throw new Error("Não foi possivel atualizar a senha");

    return true;
  }
}

module.exports = new UserService();
