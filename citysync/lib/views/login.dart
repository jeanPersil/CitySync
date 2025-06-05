import 'package:citysync/home_page.dart';
import 'package:citysync/views/cadastro.dart';
import 'package:flutter/material.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailControler = TextEditingController();
  final TextEditingController _senhaControler = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2978B5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40), // espaçamento superior opcional

              // ===== Logo =====
              Image.asset(
                "assets/images/logo.png",
                // Ajusta a altura com base na tela, sem forçar minHeight
                height: MediaQuery.of(context).size.height * 0.25,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 32),

              // ===== Formulário =====
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Campo de Email
                    TextFormField(
                      controller: _emailControler,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 153, 150, 150),
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Preencha seu e-mail";
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return "Email inválido";
                        }
                        return null;
                      },
                      onChanged: (_) {
                        if (_formKey.currentState != null) {
                          _formKey.currentState!.validate();
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // Campo de Senha
                    TextFormField(
                      controller: _senhaControler,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: "Senha",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Preencha sua senha";
                        }
                        if (value.length < 6) {
                          return "Senha com mínimo de 6 caracteres";
                        }
                        return null;
                      },
                      onChanged: (_) {
                        if (_formKey.currentState != null) {
                          _formKey.currentState!.validate();
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ===== Botão de Login =====
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF20C997),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const Homepage()),
                      );
                    }
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ===== Texto e Link de Cadastro =====
              const Text(
                "Ainda não tem uma conta?",
                style: TextStyle(color: Colors.white),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaCadastro()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF20C997),
                ),
                child: const Text("Cadastre-se!"),
              ),

              const SizedBox(height: 40), 
            ],
          ),
        ),
      ),
    );
  }
}