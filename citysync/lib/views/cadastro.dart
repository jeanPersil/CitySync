import 'package:flutter/material.dart';
import 'package:citysync/home_page.dart';
import 'package:citysync/views/login.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();

  // Controllers para todos os campos necessários
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _logradouroController = TextEditingController();
  final TextEditingController _numeroCasaController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();

  @override
  void dispose() {
    // Fechar todos os controllers quando o widget for descartado
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _telefoneController.dispose();
    _logradouroController.dispose();
    _numeroCasaController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _cepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF2978B5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Logo 
              Image.asset(
                "assets/images/logo.png",
                height: screenHeight * 0.25,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 32),

              // ===== Formulário de Cadastro =====
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Nome completo
                    TextFormField(
                      controller: _nomeController,
                      keyboardType: TextInputType.name,
                      style: const TextStyle(color: Colors.white),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: "Nome completo",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 153, 150, 150)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Preencha seu nome";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // CPF
                    TextFormField(
                      controller: _cpfController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: "CPF (somente dígitos)",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 153, 150, 150)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      maxLength: 11,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Preencha seu CPF";
                        }
                        if (value.length != 11 || !RegExp(r'^\d{11}$').hasMatch(value)) {
                          return "CPF deve ter 11 dígitos numéricos";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // E-mail
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 153, 150, 150)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Preencha seu e-mail";
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return "Email inválido";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Senha
                    TextFormField(
                      controller: _senhaController,
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
                    ),

                    const SizedBox(height: 20),

                    // Telefone
                    TextFormField(
                      controller: _telefoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: "Telefone (somente dígitos)",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 153, 150, 150)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Preencha seu telefone";
                        }
                        if (!RegExp(r'^\d{8,15}$').hasMatch(value)) {
                          return "Telefone inválido";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Logradouro
                    TextFormField(
                      controller: _logradouroController,
                      keyboardType: TextInputType.streetAddress,
                      style: const TextStyle(color: Colors.white),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: "Logradouro",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 153, 150, 150)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Preencha o logradouro";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Número da casa
                    TextFormField(
                      controller: _numeroCasaController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: "Número da casa",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 153, 150, 150)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Preencha o número da casa";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Bairro
                    TextFormField(
                      controller: _bairroController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(color: Colors.white),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: "Bairro",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 153, 150, 150)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Preencha o bairro";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Cidade
                    TextFormField(
                      controller: _cidadeController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(color: Colors.white),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: "Cidade",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 153, 150, 150)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Preencha a cidade";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Estado
                    TextFormField(
                      controller: _estadoController,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(color: Colors.white),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: "Estado",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 153, 150, 150)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Preencha o estado";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // CEP
                    TextFormField(
                      controller: _cepController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: const InputDecoration(
                        labelText: "CEP (somente dígitos)",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 153, 150, 150)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      maxLength: 8,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Preencha o CEP";
                        }
                        if (value.length != 8 || !RegExp(r'^\d{8}$').hasMatch(value)) {
                          return "CEP inválido";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ===== Botão Cadastrar =====
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
                      // Campo para a requisição POST para /cadastrar
                      // Exemplo:
                      //
                      // final response = await http.post(
                      //   Uri.parse('https://servidor.com/auth/cadastrar'),
                      //   headers: { 'Content-Type': 'application/json' },
                      //   body: jsonEncode({
                      //     'nome': _nomeController.text,
                      //     'cpf': _cpfController.text,
                      //     'email': _emailController.text,
                      //     'senha': _senhaController.text,
                      //     'telefone': _telefoneController.text,
                      //     'logradouro': _logradouroController.text,
                      //     'numero_casa': _numeroCasaController.text,
                      //     'bairro': _bairroController.text,
                      //     'cidade': _cidadeController.text,
                      //     'estado': _estadoController.text,
                      //     'cep': _cepController.text,
                      //   }),
                      // );
                      //
                      // if (response.statusCode == 201) {
                      //   Navigator.pushReplacement(
                      //     context,
                      //     MaterialPageRoute(builder: (_) => const Homepage()),
                      //   );
                      // } else {
                      //   mostrarSnackbarComErro(response.body);
                      // }

                      // Por enquanto, só navega para Home:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const Homepage()),
                      );
                    }
                  },
                  child: const Text(
                    "Cadastrar",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ===== Texto “Já tem uma conta? Faça Login” =====
              const Text(
                "Já tem uma conta?",
                style: TextStyle(color: Colors.white),
              ),
              TextButton(
                onPressed: () {
                  // Voltar para a tela de login
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const TelaLogin()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF20C997),
                ),
                child: const Text("Faça Login"),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
