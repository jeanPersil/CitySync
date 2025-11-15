import 'package:supabase_flutter/supabase_flutter.dart';
import 'validator.dart';

class AutenticacaoUsuario {
  Future<String?> login(String email, String senha) async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.auth.signInWithPassword(password: senha, email: email);
      return null;
    } on AuthException catch (e) {
      switch (e.statusCode) {
        case '400':
          return "E-mail ou senha inválidos";
        case '429':
          return "Muitas tentativas. Tente novamente em alguns minutos";
        default:
          return "Ocorreu um erro de autenticação: ${e.message}";
      }
    } catch (e) {
      return "Ocorreu um erro inesperado. Por favor, verifique sua conexão com a internet.";
    }
  }

  Future<String?> cadastrar(Map<String, dynamic> dados) async {
    try {
      final supabase = Supabase.instance.client;
      final validar = Validator();
      final cepValido = await validar.validarCepComApi(dados["cep"]);

      if (!validar.validarCPF(dados["cpf"])) {
        return "Por favor, insira um CPF válido";
      }

      if (!cepValido) {
        return "Por favor, insira um CEP válido";
      }

      final cpfExistente =
          await supabase.from("users").select().eq("cpf", dados["cpf"]);

      if (cpfExistente.isNotEmpty) {
        return "Ja existe um usuario cadastrado com esse CPF";
      }

      final response = await supabase.auth.signUp(
        password: dados["senha"],
        email: dados["email"],
      );

      if (response.user != null) {
        await supabase.from('users').insert({
          'id': response.user!.id,
          'nome': dados["nome"],
          'cpf': dados["cpf"],
          'email': dados["email"],
          'telefone': dados["telefone"],
          'fk_cidade': dados["fk_cidade"],
          'cep': dados["cep"],
        });

        return null;
      } else {
        return "Erro ao criar usuário";
      }
    } catch (e) {
      return "Erro inesperado: $e";
    }
  }

  Future<String> updateUserPassword({
    required String newPassword,
    required String email,
    required String newToken,
  }) async {
    try {
      final supabase = Supabase.instance.client;
      final AuthResponse res = await supabase.auth
          .verifyOTP(email: email, token: newToken, type: OtpType.recovery);

      if (res.session != null) {
        if (newPassword.length < 6) {
          return "A senha deve ter no mínimo 6 caracteres";
        }
        await supabase.auth.updateUser(UserAttributes(password: newPassword));
        return "Senha alterada com sucesso!";
      }

      return "Token inválido ou expirado";
    } catch (error) {
      final errorMsg = error.toString();
      if (errorMsg.contains("Invalid token") || errorMsg.contains("expired")) {
        return "Token inválido ou expirado";
      }
      return "Erro ao alterar senha: $errorMsg";
    }
  }

  Future<String> recuperar_senha(String email) async {
    try {
      final supabase = Supabase.instance.client;

      await supabase.auth.resetPasswordForEmail(email,
          redirectTo: "com.city.app://reset-password");
      return "Email de recuperação enviado! Verifique seu email.";
    } catch (error) {
      return "Erro ao enviar email de recuperação: $error";
    }
  }
}
