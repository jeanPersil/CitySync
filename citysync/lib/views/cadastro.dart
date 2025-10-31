import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:citysync/services/auth.dart';
import 'package:citysync/views/login.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});
  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cepController = TextEditingController();

  late final AnimationController _entryController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  bool _obscureText = true;
  bool _obscureConfirmText = true;
  bool _isLoading = false;
  bool _aceitaPolitica = false;
  int? _cidadeSelecionada = 1;
  final _auth = AutenticacaoUsuario();

  static final RegExp _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim  = CurvedAnimation(parent: _entryController, curve: Curves.easeInOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, .15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));
    _entryController.forward();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _telefoneController.dispose();
    _cepController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  String _digitsOnly(String v) => v.replaceAll(RegExp(r'\D'), '');

  String _normalizeEmailInput(String v) {
    final trimmed = v.trim();
    final i = trimmed.lastIndexOf('@');
    if (i < 1) return trimmed;
    final local = trimmed.substring(0, i);
    final domain = trimmed.substring(i + 1).replaceAll(' ', '').toLowerCase();
    return '$local@$domain';
  }

  bool _isValidEmail(String v) {
    if (!_emailRe.hasMatch(v)) return false;
    final parts = v.split('@');
    if (parts.length != 2) return false;
    final domain = parts[1].toLowerCase();
    if (domain.contains('gmail') && domain != 'gmail.com') return false;
    return true;
  }

  Future<void> _handleCadastro() async {
    if (!_formKey.currentState!.validate() || !_aceitaPolitica) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preencha os campos corretamente e aceite a Política de Privacidade.'),
          backgroundColor: Colors.black54,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final email = _normalizeEmailInput(_emailController.text);
    final dados = {
      "nome": _nomeController.text.trim(),
      "cpf": _digitsOnly(_cpfController.text),
      "email": email,
      "senha": _senhaController.text.trim(),
      "telefone": _digitsOnly(_telefoneController.text),
      "fk_cidade": (_cidadeSelecionada ?? 1).toString(),
      "cep": _digitsOnly(_cepController.text),
    };

    final erro = await _auth.cadastrar(dados);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Usuário cadastrado com sucesso!", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF20C997),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TelaLogin()));
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
    TextStyle? counterStyle,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF20C997), width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
      counterStyle: counterStyle,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int? maxLength,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    TextStyle? counterStyle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLength: maxLength,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: _decoration(label: label, icon: icon, suffixIcon: suffixIcon, counterStyle: counterStyle),
      inputFormatters: inputFormatters,
      validator: validator ?? (v) => (v == null || v.trim().isEmpty) ? "Campo obrigatório" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1D3D),
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: const Color(0xFF0A1D3D),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _field(
                      _nomeController, "Nome completo", Icons.person,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "Digite seu nome completo";
                        if (v.trim().length < 3) return "Nome muito curto";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _field(
                      _cpfController, "CPF", Icons.badge,
                      keyboardType: TextInputType.number,
                      maxLength: 14,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, _CpfInputFormatter()],
                      counterStyle: const TextStyle(color: Colors.white),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "Digite seu CPF";
                        final d = v.replaceAll(RegExp(r'\D'), '');
                        if (d.length != 11) return "CPF deve ter 11 dígitos";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _field(
                      _emailController, "E-mail", Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      inputFormatters: [_EmailSanitizerFormatter()],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "Digite seu e-mail";
                        final norm = _normalizeEmailInput(v);
                        return _isValidEmail(norm) ? null : "E-mail inválido";
                      },
                    ),
                    const SizedBox(height: 14),
                    _field(
                      _senhaController, "Senha", Icons.lock,
                      obscureText: _obscureText,
                      maxLength: 20,
                      counterStyle: const TextStyle(color: Colors.white),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                        onPressed: () => setState(() => _obscureText = !_obscureText),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Digite sua senha";
                        if (v.length < 6) return "Mínimo 6 caracteres";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _field(
                      _confirmarSenhaController, "Confirmar senha", Icons.lock_outline,
                      obscureText: _obscureConfirmText,
                      maxLength: 20,
                      counterStyle: const TextStyle(color: Colors.white),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmText ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                        onPressed: () => setState(() => _obscureConfirmText = !_obscureConfirmText),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Confirme sua senha";
                        if (v != _senhaController.text) return "As senhas não coincidem";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _field(
                      _telefoneController, "Telefone", Icons.phone,
                      keyboardType: TextInputType.phone,
                      maxLength: 15,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, _PhoneBrInputFormatter()],
                      counterStyle: const TextStyle(color: Colors.white),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "Digite seu telefone";
                        final d = v.replaceAll(RegExp(r'\D'), '');
                        if (d.length < 10 || d.length > 11) return "Telefone inválido";
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int>(
                      value: _cidadeSelecionada,
                      dropdownColor: const Color(0xFF1E3A5F),
                      decoration: _decoration(label: "Cidade", icon: Icons.location_city),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text("Feira de Santana", style: TextStyle(color: Colors.white))),
                      ],
                      onChanged: (v) => setState(() => _cidadeSelecionada = v),
                      validator: (v) => v == null ? "Selecione uma cidade" : null,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      _cepController, "CEP", Icons.numbers,
                      keyboardType: TextInputType.number,
                      maxLength: 9,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, _CepInputFormatter()],
                      counterStyle: const TextStyle(color: Colors.white),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return "Digite seu CEP";
                        final d = v.replaceAll(RegExp(r'\D'), '');
                        if (d.length != 8) return "CEP deve ter 8 dígitos";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _aceitaPolitica,
                          onChanged: (v) => setState(() => _aceitaPolitica = v ?? false),
                          activeColor: const Color(0xFF20C997),
                        ),
                        const Expanded(
                          child: Text(
                            'Estou de acordo com a Política de Privacidade.',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF20C997).withOpacity(_isLoading ? 0.3 : 0.6),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                )
                              : const Icon(Icons.check, size: 22),
                          label: Text(_isLoading ? "Processando..." : "Cadastrar", style: const TextStyle(fontSize: 18)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF20C997),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _isLoading ? null : _handleCadastro,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TelaLogin())),
                      child: const Text("Já tem conta? Faça login", style: TextStyle(color: Color(0xFF20C997), fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    String out;
    if (digits.length <= 3) {
      out = digits;
    } else if (digits.length <= 6) {
      out = '${digits.substring(0, 3)}.${digits.substring(3)}';
    } else if (digits.length <= 9) {
      out = '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6)}';
    } else {
      out = '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9, digits.length.clamp(9, 11))}';
    }
    if (out.length > 14) out = out.substring(0, 14);
    return TextEditingValue(text: out, selection: TextSelection.collapsed(offset: out.length));
  }
}

class _CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    String out;
    if (digits.length <= 5) {
      out = digits;
    } else {
      out = '${digits.substring(0, 5)}-${digits.substring(5, digits.length.clamp(5, 8))}';
    }
    if (out.length > 9) out = out.substring(0, 9);
    return TextEditingValue(text: out, selection: TextSelection.collapsed(offset: out.length));
  }
}

class _PhoneBrInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    String out;
    if (digits.isEmpty) {
      out = '';
    } else if (digits.length <= 2) {
      out = '(${digits.substring(0, digits.length)}';
    } else if (digits.length <= 6) {
      out = '(${digits.substring(0, 2)}) ${digits.substring(2)}';
    } else if (digits.length <= 10) {
      out = '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
    } else {
      out = '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7, digits.length.clamp(7, 11))}';
    }
    if (out.length > 15) out = out.substring(0, 15);
    return TextEditingValue(text: out, selection: TextSelection.collapsed(offset: out.length));
  }
}

class _EmailSanitizerFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(' ', '');
    final at = text.lastIndexOf('@');
    if (at > 0 && at < text.length - 1) {
      final local = text.substring(0, at);
      final domain = text.substring(at + 1).toLowerCase();
      text = '$local@$domain';
    }
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
