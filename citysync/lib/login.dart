import 'package:citysync/homePage.dart';
import 'package:flutter/material.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController _emailControler = TextEditingController();
  final TextEditingController _senhaControler = TextEditingController();
  String? erro_email;
  String? erro_senha;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2978B5), // Azul principal
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/logo.png",
                height: 300,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailControler,
                decoration: InputDecoration(
                  labelText: "Email",
                  errorText: erro_email,
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: const Color.fromARGB(255, 153, 150, 150)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _senhaControler,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Senha",
                  errorText: erro_senha,
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 40),
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
                    if (_emailControler.text.isEmpty) {
                      setState(() {
                        erro_email = "Preencha seu e-mail";
                      });
                      return;
                    }

                    if (_senhaControler.text.isEmpty) {
                      setState(() {
                        erro_senha = "Preencha sua senha";
                      });
                      return;
                    }
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Homepage()),
                    );
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Ainda não tem uma conta?",
                style: TextStyle(color: Colors.white),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Cadastre-se!",
                  style: TextStyle(color: Color(0xFF20C997)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
