import 'package:citysync/views/modificarSenha/alterarSenha.dart';
import 'package:flutter/material.dart';
import '../../services/auth.dart';

class Esqueceu_senha_view extends StatelessWidget {
  Esqueceu_senha_view({super.key});

  final _emailController = TextEditingController();
  final autenticacaoUsuario = AutenticacaoUsuario();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1D3D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.1),

              // Logo
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  "assets/images/logo.png",
                  height: screenHeight * 0.2,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Esqueceu a sua senha?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Coloque o seu endereço de email abaixo e iremos te enviar um token para mudar a sua senha!",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "E-mail",
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: Icon(Icons.email, color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.08),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF20C997), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF20C997).withOpacity(0.6),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF20C997),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () async {
                            if (_emailController.text.isEmpty ||
                                !_emailController.text.contains('@')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Por favor, insira um email válido."),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            String res = await autenticacaoUsuario
                                .recuperar_senha(_emailController.text);

                            if (res ==
                                "Email de recuperação enviado! Verifique seu email.") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(res),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AlterarSenha(
                                      email: _emailController.text),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(res),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            "Enviar Token",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: const Color(0xFF20C997).withOpacity(0.3),
                      width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "O que vai acontecer?",
                      style: TextStyle(
                        color: Color(0xFF20C997),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildStepRow("1",
                        "Você vai receber um email com um token de recuperação."),
                    const SizedBox(height: 12),
                    _buildStepRow("2",
                        "Verifique sua caixa de spam se não encontrar na caixa de entrada."),
                    const SizedBox(height: 12),
                    _buildStepRow("3",
                        "Coloque o token que você recebeu no email na próxima tela."),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Botão para voltar
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Voltar para login",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(String stepNumber, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF20C997),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
