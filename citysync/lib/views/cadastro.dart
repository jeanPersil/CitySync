import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:citysync/services/auth.dart';
import 'package:citysync/views/login.dart';
import 'package:citysync/views/politica_privacidade.dart';

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
  final _logradouroController = TextEditingController();
  final _numeroCasaController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cepController = TextEditingController();

  late final AnimationController _scaleController;
  late final AnimationController _entryController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  bool _obscureText = true;
  bool _obscureConfirmText = true;
  bool _isLoading = false;
  bool _aceitaPolitica = false;
  int? _cidadeSelecionada = 1;
  final auth = AutenticacaoUsuario();

  @override
  void initState(){
    super.initState();
    _scaleController = AnimationController(vsync: this, duration: const Duration(seconds:2))..repeat(reverse:true);
    _scaleAnim = Tween<double>(begin:0.95, end:1.0).animate(CurvedAnimation(parent:_scaleController, curve:Curves.easeInOut));
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds:800));
    _fadeAnim  = Tween<double>(begin:0.0, end:1.0).animate(CurvedAnimation(parent:_entryController, curve:Curves.easeInOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0,0.3), end: Offset.zero).animate(CurvedAnimation(parent:_entryController, curve:Curves.easeOut));
    _entryController.forward();
  }

  @override
  void dispose(){
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _telefoneController.dispose();
    _logradouroController.dispose();
    _numeroCasaController.dispose();
    _bairroController.dispose();
    _cepController.dispose();
    _scaleController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  String _digitsOnly(String v) => v.replaceAll(RegExp(r'\D'), '');

  Future<void> _handleCadastro() async {
    if (!_formKey.currentState!.validate() || !_aceitaPolitica) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, preencha todos os campos corretamente e aceite a Política de Privacidade.'),
          backgroundColor: Colors.black54,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    final dadosCadastro = {
      "nome": _nomeController.text.trim(),
      "cpf": _digitsOnly(_cpfController.text),
      "email": _emailController.text.trim(),
      "senha": _senhaController.text.trim(),
      "telefone": _digitsOnly(_telefoneController.text),
      "fk_cidade": _cidadeSelecionada.toString(),
      "cep": _digitsOnly(_cepController.text),
    };
    final resultado = await auth.cadastrar(dadosCadastro);
    setState(() => _isLoading = false);
    if (resultado != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao cadastrar usuário: $resultado.", style: const TextStyle(color: Colors.white)),
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

  InputDecoration _decoration({required String label, required IconData icon, Widget? suffixIcon, TextStyle? counterStyle}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF20C997), width:2.0)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color:Colors.redAccent, width:1.5)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color:Colors.redAccent, width:2.0)),
      counterStyle: counterStyle,
      contentPadding: const EdgeInsets.symmetric(vertical:16, horizontal:20),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius:10, offset: const Offset(0,5)),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        maxLength: maxLength,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: _decoration(label: label, icon: icon, suffixIcon: suffixIcon, counterStyle: counterStyle),
        inputFormatters: inputFormatters,
        validator: validator ?? (value){ if(value==null||value.trim().isEmpty) return "Campo obrigatório"; return null; },
      ),
    );
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
              const SizedBox(height: 20),
              const Text(
                "Criar Nova Conta",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius:10, color:Colors.black45, offset:Offset(0,2))],
                ),
              ),
              const SizedBox(height:30),
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius:20, spreadRadius:5, offset: const Offset(0,10))
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _field(_nomeController, "Nome completo", Icons.person, validator: (value){ if(value==null||value.trim().isEmpty) return "Por favor, digite seu nome completo."; if(value.trim().length<3) return "Nome muito curto."; return null; }),
                      const SizedBox(height:15),
                      _field(_cpfController, "CPF", Icons.badge, keyboardType: TextInputType.number, maxLength:14, inputFormatters:[FilteringTextInputFormatter.digitsOnly, _CpfInputFormatter()], counterStyle: const TextStyle(color: Colors.white), validator: (value){ if(value==null||value.trim().isEmpty) return "Por favor, digite seu CPF."; final d=value.replaceAll(RegExp(r'\D'),''); if(d.length!=11) return "CPF deve ter 11 dígitos."; return null; }),
                      const SizedBox(height:15),
                      _field(_emailController, "Email", Icons.email, keyboardType: TextInputType.emailAddress, validator: (value){ if(value==null||value.trim().isEmpty) return "Por favor, digite seu e-mail."; final emailRegex=RegExp(r'^[^@]+@[^@]+\.[^@]+'); if(!emailRegex.hasMatch(value)) return "E-mail inválido."; return null; }),
                      const SizedBox(height:15),
                      _field(_senhaController, "Senha", Icons.lock, obscureText:_obscureText, maxLength:20, counterStyle: const TextStyle(color: Colors.white), suffixIcon: IconButton(icon: Icon(_obscureText?Icons.visibility_off:Icons.visibility, color:Colors.white70), onPressed:(){ setState(()=>_obscureText=!_obscureText);} ), validator: (value){ if(value==null||value.isEmpty) return "Por favor, digite sua senha."; if(value.length<6) return "Senha deve ter no mínimo 6 caracteres."; return null; }),
                      const SizedBox(height:15),
                      _field(_confirmarSenhaController, "Confirmar Senha", Icons.lock_outline, obscureText:_obscureConfirmText, maxLength:20, counterStyle: const TextStyle(color: Colors.white), suffixIcon: IconButton(icon: Icon(_obscureConfirmText?Icons.visibility_off:Icons.visibility, color:Colors.white70), onPressed:(){ setState(()=>_obscureConfirmText=!_obscureConfirmText);} ), validator: (value){ if(value==null||value.isEmpty) return "Por favor, confirme sua senha."; if(value != _senhaController.text) return "As senhas não coincidem."; return null; }),
                      const SizedBox(height:15),
                      _field(_telefoneController, "Telefone", Icons.phone, keyboardType:TextInputType.phone, maxLength:15, inputFormatters:[FilteringTextInputFormatter.digitsOnly, _PhoneBrInputFormatter()], counterStyle: const TextStyle(color: Colors.white), validator: (value){ if(value==null||value.trim().isEmpty) return "Por favor, digite seu telefone."; final d=value.replaceAll(RegExp(r'\D'),''); if(d.length<10||d.length>11) return "Telefone inválido."; return null; }),
                      const SizedBox(height:20),
                      const Divider(color:Colors.white38),
                      const SizedBox(height:10),
                      DropdownButtonFormField<int>(
                        value: _cidadeSelecionada,
                        dropdownColor: const Color(0xFF1E3A5F),
                        decoration: _decoration(label:"Cidade", icon:Icons.location_city),
                        items: const [
                          DropdownMenuItem(value:1, child: Text("Feira de Santana", style:TextStyle(color:Colors.white))),
                        ],
                        onChanged:(int? novo){ setState(()=>_cidadeSelecionada=novo); },
                        validator:(value){ if(value==null) return "Por favor, selecione uma cidade"; return null; },
                      ),
                      const SizedBox(height:15),
                      _field(_cepController, "CEP", Icons.numbers, keyboardType:TextInputType.number, maxLength:9, inputFormatters:[FilteringTextInputFormatter.digitsOnly, _CepInputFormatter()], counterStyle: const TextStyle(color: Colors.white), validator: (value){ if(value==null||value.trim().isEmpty) return "Por favor, digite seu CEP."; final d=value.replaceAll(RegExp(r'\D'),''); if(d.length!=8) return "CEP deve ter 8 dígitos."; return null; }),
                      const SizedBox(height:20),
                      Row(
                        children: [
                          Checkbox(
                            value: _aceitaPolitica,
                            onChanged: (bool? v){ setState(()=> _aceitaPolitica = v ?? false); },
                            activeColor: const Color(0xFF20C997),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PoliticaPrivacidadePage())),
                              child: RichText(
                                text: const TextSpan(
                                  text: 'Estou de acordo com a ',
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                  children: [
                                    TextSpan(
                                      text: 'Política de Privacidade.',
                                      style: TextStyle(color: Color(0xFF80D8FF), decoration: TextDecoration.underline, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height:30),
              SizedBox(
                width: double.infinity,
                height:55,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds:300),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), boxShadow:[BoxShadow(color: const Color(0xFF20C997).withOpacity(_isLoading?0.3:0.6), blurRadius:10, offset: const Offset(0,5))]),
                  child: ElevatedButton.icon(
                    icon: _isLoading ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2,valueColor:AlwaysStoppedAnimation<Color>(Colors.white))) : const Icon(Icons.check, size:22),
                    label: _isLoading ? const Text("Processando...", style: TextStyle(fontSize:16)) : const Text("Cadastrar", style: TextStyle(fontSize:18)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF20C997), foregroundColor: Colors.white, elevation:0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: _isLoading ? null : _handleCadastro,
                  ),
                ),
              ),
              const SizedBox(height:20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Já tem uma conta?", style: TextStyle(color:Colors.white70)),
                  const SizedBox(width:5),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TelaLogin())),
                    child: const Text("Faça Login", style: TextStyle(color:Color(0xFF20C997), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height:30),
            ],
          ),
        ),
      ),
    );
  }
}

class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue){
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    String out;
    if (digits.length <= 3) {
      out = digits;
    } else if (digits.length <= 6) {
      out = '${digits.substring(0,3)}.${digits.substring(3)}';
    } else if (digits.length <= 9) {
      out = '${digits.substring(0,3)}.${digits.substring(3,6)}.${digits.substring(6)}';
    } else {
      out = '${digits.substring(0,3)}.${digits.substring(3,6)}.${digits.substring(6,9)}-${digits.substring(9,digits.length.clamp(9,11))}';
    }
    if (out.length > 14) out = out.substring(0,14);
    return TextEditingValue(text: out, selection: TextSelection.collapsed(offset: out.length));
  }
}

class _CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue){
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    String out;
    if (digits.length <= 5) {
      out = digits;
    } else {
      out = '${digits.substring(0,5)}-${digits.substring(5, digits.length.clamp(5,8))}';
    }
    if (out.length > 9) out = out.substring(0,9);
    return TextEditingValue(text: out, selection: TextSelection.collapsed(offset: out.length));
  }
}

class _PhoneBrInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue){
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    String out;
    if (digits.isEmpty) {
      out = '';
    } else if (digits.length <= 2) {
      out = '(${digits.substring(0,digits.length)}';
    } else if (digits.length <= 6) {
      out = '(${digits.substring(0,2)}) ${digits.substring(2)}';
    } else if (digits.length <= 10) {
      out = '(${digits.substring(0,2)}) ${digits.substring(2,6)}-${digits.substring(6)}';
    } else {
      out = '(${digits.substring(0,2)}) ${digits.substring(2,7)}-${digits.substring(7, digits.length.clamp(7,11))}';
    }
    if (out.length > 15) out = out.substring(0,15);
    return TextEditingValue(text: out, selection: TextSelection.collapsed(offset: out.length));
  }
}
