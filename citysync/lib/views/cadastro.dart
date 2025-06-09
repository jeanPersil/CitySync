import 'package:citysync/services/auth.dart';
import 'package:citysync/views/login.dart';
import 'package:flutter/material.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroCasaController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cepController = TextEditingController();

  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  bool _obscureText = true;

 
  int? _cidadeSelecionada = 1;
  final auth = AutenticacaoUsuario();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _telefoneController.dispose();
    _logradouroController.dispose();
    _numeroCasaController.dispose();
    _bairroController.dispose();
    _cepController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white),
      prefixIcon: Icon(icon, color: Colors.white),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white12,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int? maxLength,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLength: maxLength,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: _buildInputDecoration(
          labelText: label, icon: icon, suffixIcon: suffixIcon),
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return "Campo obrigatório";
            }
            return null;
          },
    );
  }

  void _handleCadastro() async {
    if (_formKey.currentState!.validate()) {
      final dadosCadastro = {
        "nome": _nomeController.text.trim(),
        "cpf": _cpfController.text.trim(),
        "email": _emailController.text.trim(),
        "senha": _senhaController.text.trim(),
        "telefone": _telefoneController.text.trim(),
        "logradouro": _logradouroController.text.trim(),
        "numero": _numeroCasaController.text.trim(),
        "bairro": _bairroController.text.trim(),
        "cidade": _cidadeSelecionada.toString(),
        "cep": _cepController.text.trim(),
      };

      final resultado = await auth.cadastrar(dadosCadastro);

      if (!resultado["sucesso"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['mensagem'] ?? 'Erro desconhecido'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['mensagem']),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TelaLogin()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos corretamente.'),
          backgroundColor: Colors.black,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 30),
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
                child: Image.asset("assets/images/logo.png", height: 200),
              ),
              const SizedBox(height: 20),
              const Text(
                "Criar Nova Conta",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildField(
                      _nomeController,
                      "Nome completo",
                      Icons.person,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Por favor, digite seu nome completo.";
                        }
                        if (value.trim().length < 3) {
                          return "Nome muito curto.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildField(
                      _cpfController,
                      "CPF (somente dígitos)",
                      Icons.badge,
                      keyboardType: TextInputType.number,
                      maxLength: 11,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Por favor, digite seu CPF.";
                        }
                        if (value.length != 11 ||
                            !RegExp(r'^\d{11}$').hasMatch(value)) {
                          return "CPF deve ter 11 dígitos numéricos válidos.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildField(
                      _emailController,
                      "Email",
                      Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Por favor, digite seu e-mail.";
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return "E-mail inválido.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildField(
                      _senhaController,
                      "Senha",
                      Icons.lock,
                      obscureText: _obscureText,
                      maxLength: 20,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Por favor, digite sua senha.";
                        }
                        if (value.length < 6) {
                          return "Senha deve ter no mínimo 6 caracteres.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildField(
                      _telefoneController,
                      "Telefone (somente dígitos)",
                      Icons.phone,
                      keyboardType: TextInputType.phone,
                      maxLength: 12,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Por favor, digite seu telefone.";
                        }
                        if (!RegExp(r'^\d{10,12}$').hasMatch(value)) {
                          return "Telefone inválido (ex: DDD+Número).";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white38),
                    const SizedBox(height: 10),
                    _buildField(
                      _logradouroController,
                      "Logradouro",
                      Icons.home,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Por favor, digite seu logradouro.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            _numeroCasaController,
                            "Número",
                            Icons.looks_one,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Campo obrigatório";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildField(
                            _bairroController,
                            "Bairro",
                            Icons.location_city,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Campo obrigatório";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<int>(
                      value: _cidadeSelecionada,
                      decoration: _buildInputDecoration(
                        labelText: "Cidade",
                        icon: Icons.location_city,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Text("Feira de Santana"),
                        ),
                      ],
                      onChanged: (int? novoValor) {
                        setState(() {
                          _cidadeSelecionada = novoValor;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Por favor, selecione uma cidade";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildField(
                      _cepController,
                      "CEP (somente dígitos)",
                      Icons.numbers,
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Por favor, digite seu CEP.";
                        }
                        if (value.length != 8 ||
                            !RegExp(r'^\d{8}$').hasMatch(value)) {
                          return "CEP deve ter 8 dígitos numéricos válidos.";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label:
                      const Text("Cadastrar", style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF20C997),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _handleCadastro,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Já tem uma conta?",
                      style: TextStyle(color: Colors.white70)),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const TelaLogin()));
                    },
                    child: const Text("Faça Login",
                        style: TextStyle(color: Color(0xFF20C997))),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
