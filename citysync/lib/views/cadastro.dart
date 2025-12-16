import 'package:citysync/services/auth.dart';
import 'package:citysync/views/login.dart';
import 'package:flutter/material.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro>
    with TickerProviderStateMixin {
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

  late final AnimationController _scaleAnimationController;
  late final AnimationController _entryAnimationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _obscureText = true;
  bool _isLoading = false;

  int? _cidadeSelecionada = 1;
  final auth = AutenticacaoUsuario();

  @override
  void initState() {
    super.initState();

    // Controlador para a animação de escala (pulsação)
    _scaleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Controlador para as animações de entrada (fade e slide)
    _entryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryAnimationController,
      curve: Curves.easeOut,
    ));

    _entryAnimationController.forward();
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
    _scaleAnimationController.dispose();
    _entryAnimationController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required IconData icon,
    Widget? suffixIcon,
    TextStyle? counterStyle,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF20C997), width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2.0),
      ),
      errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
      counterStyle: counterStyle,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
    TextStyle? counterStyle,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        maxLength: maxLength,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: _buildInputDecoration(
          labelText: label,
          icon: icon,
          suffixIcon: suffixIcon,
          counterStyle: counterStyle,
        ),
        validator: validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return "Campo obrigatório";
              }
              return null;
            },
      ),
    );
  }

  void _handleCadastro() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final dadosCadastro = {
        "nome": _nomeController.text.trim(),
        "cpf": _cpfController.text.trim(),
        "email": _emailController.text.trim(),
        "senha": _senhaController.text.trim(),
        "telefone": _telefoneController.text.trim(),
        "fk_cidade": _cidadeSelecionada.toString(),
        "cep": _cepController.text.trim(),
      };

      final resultado = await auth.cadastrar(dadosCadastro);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (resultado != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao cadastrar usuario: $resultado."),
            backgroundColor: const Color(0xFFFF6B6B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Usuário cadastrado com sucesso!"),
          backgroundColor: const Color(0xFF20C997),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TelaLogin()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, preencha todos os campos corretamente.'),
          backgroundColor: Colors.black54,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1D3D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Logo com animação
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child:
                            Image.asset("assets/images/logo.png", height: 180),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    "Criar Nova Conta",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black45,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Card do formulário
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A5F).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
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
                            counterStyle:
                                const TextStyle(color: Colors.white70),
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
                            counterStyle:
                                const TextStyle(color: Colors.white70),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white70,
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
                            counterStyle:
                                const TextStyle(color: Colors.white70),
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

                          // Dropdown de cidade
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: DropdownButtonFormField<int>(
                              initialValue: _cidadeSelecionada,
                              dropdownColor: const Color(0xFF1E3A5F),
                              decoration: _buildInputDecoration(
                                labelText: "Cidade",
                                icon: Icons.location_city,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text(
                                    "Feira de Santana",
                                    style: TextStyle(color: Colors.white),
                                  ),
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
                          ),
                          const SizedBox(height: 15),
                          _buildField(
                            _cepController,
                            "CEP (somente dígitos)",
                            Icons.numbers,
                            keyboardType: TextInputType.number,
                            maxLength: 8,
                            counterStyle:
                                const TextStyle(color: Colors.white70),
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
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Botão de cadastro
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF20C997)
                                .withValues(alpha: _isLoading ? 0.3 : 0.6),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.check, size: 22),
                        label: _isLoading
                            ? const Text("Processando...",
                                style: TextStyle(fontSize: 16))
                            : const Text("Cadastrar",
                                style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF20C997),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isLoading ? null : _handleCadastro,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Link para login
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Já tem uma conta?",
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(width: 5),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF20C997).withValues(alpha: 0.1),
                              const Color(0xFF20C997).withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const TelaLogin()));
                          },
                          child: const Text("Faça Login",
                              style: TextStyle(
                                color: Color(0xFF20C997),
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}