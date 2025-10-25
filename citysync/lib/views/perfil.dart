import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:citysync/views/login.dart';

const Color kBgNavy = Color(0xFF0B223D);
const Color kCardBg = Color(0xFFF4F6F8);
const Color kTextMain = Colors.white;
const Color kDialogBlue = Color(0xFF1E3A5F);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  late Future<Map<String, dynamic>?> _profileFuture;
  StreamSubscription<AuthState>? _authSub;
  String? _lastUserId;

  ThemeData get _lockedTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBgNavy,
        appBarTheme: const AppBarTheme(
          backgroundColor: kBgNavy,
          elevation: 0,
          foregroundColor: kTextMain,
          titleTextStyle:
              TextStyle(color: kTextMain, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        colorScheme: const ColorScheme.dark(
          surface: kBgNavy,
          primary: kCardBg,
          onPrimary: Colors.black87,
          onSurface: kTextMain,
          secondary: kDialogBlue,
          onSecondary: kTextMain,
        ),
        cardColor: kCardBg,
        dialogBackgroundColor: kDialogBlue,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: kTextMain),
          bodyMedium: TextStyle(color: kTextMain),
          titleMedium: TextStyle(color: kTextMain),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: kBgNavy,
          textColor: Colors.black87,
          titleTextStyle:
              TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15),
          subtitleTextStyle: TextStyle(color: Colors.black87),
        ),
      );

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
    _authSub = _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;
      if (event == AuthChangeEvent.signedOut || session == null) {
        if (!mounted) return;
        _goToLogin();
      } else {
        if (mounted) setState(() => _profileFuture = _loadProfile());
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _goToLogin();
      return null;
    }
    _lastUserId = user.id;
    debugPrint('ProfileScreen: currentUser.id = $_lastUserId');
    try {
      final data = await _supabase.from('users').select('*').eq('id', user.id).maybeSingle();
      if (data == null) {
        debugPrint('ProfileScreen: no record found in users for id = $_lastUserId');
        final insertResult = await _supabase
            .from('users')
            .insert({
              'id': user.id,
              'nome': '',
              'email': user.email ?? '',
              'cpf': '',
              'telefone': '',
              'cep': '',
            })
            .select()
            .maybeSingle();
        if (insertResult == null) {
          debugPrint('ProfileScreen: failed to insert new user record for id = $_lastUserId');
          return null;
        }
        return Map<String, dynamic>.from(insertResult);
      }
      return Map<String, dynamic>.from(data);
    } catch (e) {
      debugPrint('ProfileScreen _loadProfile error: $e');
      return null;
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TelaLogin()),
      (r) => false,
    );
  }

  String _digitsOnly(String v) => v.replaceAll(RegExp(r'\D'), '');

  Future<void> _updateUserField({
    required String column,
    required String value,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _goToLogin();
      return;
    }
    String toSave = value;
    if (column == 'telefone' || column == 'cep') {
      toSave = _digitsOnly(value);
    }
    if (column == 'email') {
      try {
        await _supabase.auth.updateUser(UserAttributes(email: value));
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('E-mail atualizado no perfil; no Auth pode exigir reautenticação.'),
            ),
          );
        }
      }
    }
    try {
      final updated = await _supabase
          .from('users')
          .update({column: toSave})
          .eq('id', user.id)
          .select()
          .maybeSingle() as Map<String, dynamic>?;
      if (!mounted) return;
      setState(() {
        _profileFuture = Future.value(
          updated == null ? null : Map<String, dynamic>.from(updated),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informação atualizada com sucesso!')),
      );
    } catch (e) {
      debugPrint('ProfileScreen _updateUserField error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar a informação.')),
        );
      }
    }
  }

  Future<void> _openEditDialog({
    required String titulo,
    required String column,
    required String initialValue,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => Theme(
        data: _lockedTheme.copyWith(
          dialogBackgroundColor: kDialogBlue,
          colorScheme: _lockedTheme.colorScheme.copyWith(
            surface: kDialogBlue,
            onSurface: kTextMain,
            primary: kTextMain,
            onPrimary: kDialogBlue,
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: const TextStyle(color: Colors.white70),
            hintStyle: const TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.10),
          ),
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.edit, color: kTextMain),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: kTextMain,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              autofocus: true,
              style: const TextStyle(color: kTextMain),
              decoration: const InputDecoration(labelText: 'Novo valor'),
              validator: validator,
              inputFormatters: inputFormatters,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.15),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(ctx).pop();
                  await _updateUserField(
                    column: column,
                    value: controller.text.trim(),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  String _maskCPF(String? v) {
    if (v == null) return '';
    final d = v.replaceAll(RegExp(r'\D'), '');
    if (d.length != 11) return v;
    return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6, 9)}-${d.substring(9)}';
  }

  String _maskCEP(String? v) {
    if (v == null) return '';
    final d = v.replaceAll(RegExp(r'\D'), '');
    if (d.length != 8) return v;
    return '${d.substring(0, 5)}-${d.substring(5)}';
  }

  String _maskPhoneBR(String? v) {
    if (v == null) return '';
    final d = v.replaceAll(RegExp(r'\D'), '');
    if (d.length == 11) {
      return '(${d.substring(0, 2)}) ${d.substring(2, 7)}-${d.substring(7)}';
    } else if (d.length == 10) {
      return '(${d.substring(0, 2)}) ${d.substring(2, 6)}-${d.substring(6)}';
    }
    return v;
  }

  String? _vazio(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Preencha este campo' : null;

  String? _validaEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Preencha o e-mail';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'E-mail inválido';
  }

  String? _validaTelefone(String? v) {
    final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
    return (d.length == 10 || d.length == 11) ? null : 'Telefone deve ter 10–11 dígitos';
  }

  String? _validaCEP(String? v) {
    final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
    return d.length == 8 ? null : 'CEP deve ter 8 dígitos';
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _lockedTheme,
      child: Scaffold(
        appBar: AppBar(title: const Text('Meu Perfil')),
        body: FutureBuilder<Map<String, dynamic>?>(
          future: _profileFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: kCardBg));
            }
            if (!snap.hasData || snap.data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Perfil não encontrado.', style: TextStyle(color: kTextMain)),
                    const SizedBox(height: 8),
                    Text('Usuário ID = ${_lastUserId ?? '-'}', style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() => _profileFuture = _loadProfile()),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            final data = snap.data!;
            final nome = (data['nome'] ?? '') as String;
            final email = (data['email'] ?? '') as String;
            final cpf = (data['cpf'] ?? '') as String;
            final telefone = (data['telefone'] ?? '') as String;
            final cep = (data['cep'] ?? '') as String;

            return RefreshIndicator(
              onRefresh: () async {
                setState(() => _profileFuture = _loadProfile());
                await _profileFuture;
              },
              color: kCardBg,
              backgroundColor: kBgNavy,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: kCardBg,
                      child: Text(
                        (nome.isNotEmpty ? nome[0] : '?').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      nome.isEmpty ? 'Usuário' : nome,
                      style: const TextStyle(
                        color: kTextMain,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('Informações pessoais'),
                  _buildInfoTile(
                    icon: Icons.badge_outlined,
                    label: 'Nome',
                    value: nome,
                    editable: true,
                    onEdit: () => _openEditDialog(
                      titulo: 'Editar nome',
                      column: 'nome',
                      initialValue: nome,
                      validator: _vazio,
                    ),
                  ),
                  _buildInfoTile(
                    icon: Icons.email_outlined,
                    label: 'E-mail',
                    value: email,
                    editable: true,
                    onEdit: () => _openEditDialog(
                      titulo: 'Editar e-mail',
                      column: 'email',
                      initialValue: email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validaEmail,
                    ),
                  ),
                  _buildInfoTile(
                    icon: Icons.credit_card,
                    label: 'CPF',
                    value: _maskCPF(cpf),
                    editable: false,
                  ),
                  _buildInfoTile(
                    icon: Icons.phone_outlined,
                    label: 'Telefone',
                    value: _maskPhoneBR(telefone),
                    editable: true,
                    onEdit: () => _openEditDialog(
                      titulo: 'Editar telefone',
                      column: 'telefone',
                      initialValue: _maskPhoneBR(telefone),
                      keyboardType: TextInputType.phone,
                      validator: _validaTelefone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _PhoneBrInputFormatter(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _SectionTitle('Endereço'),
                  _buildInfoTile(
                    icon: Icons.location_on_outlined,
                    label: 'CEP',
                    value: _maskCEP(cep),
                    editable: true,
                    onEdit: () => _openEditDialog(
                      titulo: 'Editar CEP',
                      column: 'cep',
                      initialValue: _maskCEP(cep),
                      keyboardType: TextInputType.number,
                      validator: _validaCEP,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _CepInputFormatter(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kTextMain,
                      side: BorderSide(color: kTextMain.withOpacity(0.7)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                      await _supabase.auth.signOut();
                      if (!mounted) return;
                      _goToLogin();
                    },
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Sair'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool editable = false,
    VoidCallback? onEdit,
  }) {
    return Card(
      color: kCardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: kBgNavy),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(color: Colors.black87),
        ),
        trailing: editable
            ? IconButton(
                icon: const Icon(Icons.edit, color: Colors.black87),
                onPressed: onEdit,
                tooltip: 'Editar',
              )
            : null,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: kCardBg,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _CepInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    String out = digits;
    if (digits.length > 5) {
      out = '${digits.substring(0, 5)}-${digits.substring(5, digits.length.clamp(5, 8))}';
    }
    if (out.length > 9) out = out.substring(0, 9);
    final offset = out.length;
    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

class _PhoneBrInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    String out;
    if (digits.isEmpty) {
      out = '';
    } else if (digits.length <= 2) {
      out = '(${digits.substring(0, digits.length)}';
    } else if (digits.length <= 6) {
      final ddd = digits.substring(0, 2);
      final p1 = digits.substring(2);
      out = '($ddd) $p1';
    } else if (digits.length <= 10) {
      final ddd = digits.substring(0, 2);
      final p1 = digits.substring(2, 6);
      final p2 = digits.substring(6);
      out = '($ddd) $p1-$p2';
    } else {
      final ddd = digits.substring(0, 2);
      final p1 = digits.substring(2, 7);
      final p2 = digits.substring(7, digits.length.clamp(7, 11));
      out = '($ddd) $p1-$p2';
    }
    if (out.length > 15) out = out.substring(0, 15);
    final offset = out.length;
    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
