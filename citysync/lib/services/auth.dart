import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AutenticacaoUsuario {
  Future<Map<String, dynamic>> login(String email, String senha) async {
    final String _urlBase = "http://192.168.0.16:5000/login_user";
    try {
      final resposta = await http.post(
        Uri.parse(_urlBase),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "senha": senha,
        }),
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        return {
          "sucesso": true,
          "user_id": dados["user_id"],
          "nome_usuario": dados["nome_usuario"],
        };
      } else {
        final erro = jsonDecode(resposta.body);
        return {
          "sucesso": false,
          "mensagem": erro["erro"] ?? "Erro desconhecido",
        };
      }
    } catch (e) {
      return {
        "sucesso": false,
        "mensagem": "Erro de conexão: $e",
      };
    }
  }

  Future<Map<String, dynamic>> cadastrar(Map<String, dynamic> dados) async {
    final String _urlBase = "http://192.168.0.16:5000/cadastrar_user";
    try {
      final resposta = await http.post(
        Uri.parse(_urlBase),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(dados),
      );

      if (resposta.statusCode == 200) {
        final respostaJson = jsonDecode(resposta.body);
        return {
          "sucesso": true,
          "mensagem":
              respostaJson["mensagem"] ?? "Cadastro realizado com sucesso!",
        };
      } else {
        final erro = jsonDecode(resposta.body);
        return {
          "sucesso": false,
          "mensagem": erro["erro"] ?? "Erro desconhecido no cadastro",
        };
      }
    } catch (e) {
      return {
        "sucesso": false,
        "mensagem": "Erro de conexão: $e",
      };
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
