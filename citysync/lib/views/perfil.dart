import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:citysync/views/login.dart';

const Color kBgNavy     = Color(0xFF0B223D);
const Color kCardBg     = Color(0xFFF4F6F8);
const Color kTextMain   = Colors.white;
const Color kDialogBlue = Color(0xFF1E3A5F);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();
  late Future<Map<String, dynamic>?> _profileFuture;
  StreamSubscription<AuthState>? _authSub;

  ThemeData get _lockedTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBgNavy,
        appBarTheme: const AppBarTheme(
          backgroundColor: kBgNavy,
          elevation: 0,
          foregroundColor: kTextMain,
          titleTextStyle: TextStyle(
            color: kTextMain, fontSize: 20, fontWeight: FontWeight.w600),
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
      );

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();

    _authSub = _supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedOut || data.session == null) {
        if (!mounted) return;
        _goToLogin();
        return;
      }
      _recarregarPerfil();
    });
  }

  void _recarregarPerfil() {
    final future = _loadProfile();
    setState(() {
      _profileFuture = future;
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _loadProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final data = await _supabase
        .from('users')
        .select('*')
        .eq('id', user.id)
        .maybeSingle();

    return data == null ? null : Map<String, dynamic>.from(data);
  }

  void _goToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => TelaLogin()),
      (route) => false,
    );
  }


  Future<void> _selecionarImagem() async {
    final XFile? img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (img == null) return;

    await _uploadImagemBytes(img);
  }

  Future<void> _uploadImagemBytes(XFile xfile) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final bucket = "imagensPerfil";
    final path = "${user.id}.jpg";

    try {
      Uint8List bytes = await xfile.readAsBytes();

      try {
        await _supabase.storage.from(bucket).remove([path]);
      } catch (_) {}

      await _supabase.storage.from(bucket).uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

     
      final baseUrl = _supabase.storage.from(bucket).getPublicUrl(path);
      final url = "$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}";

      await _supabase
          .from("users")
          .update({"foto_url": url})
          .eq("id", user.id);

      _recarregarPerfil();

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Foto atualizada!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Erro: $e")));
      }
    }
  }


  Future<void> _updateUserField({
    required String column,
    required String value,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    if (column == 'email') {
      try {
        await _supabase.auth.updateUser(UserAttributes(email: value));
      } catch (_) {}
    }

    final data = await _supabase
        .from('users')
        .update({column: value})
        .eq('id', user.id)
        .select()
        .maybeSingle();

    setState(() {
      _profileFuture = Future.value(data);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Informação atualizada!")),
      );
    }
  }

  Future<void> _openEditDialog({
    required String titulo,
    required String column,
    required String initialValue,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => Theme(
        data: _lockedTheme,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.edit, color: kTextMain),
              const SizedBox(width: 8),
              Expanded(
                child: Text(titulo,
                    style: const TextStyle(
                        color: kTextMain, fontWeight: FontWeight.w700)),
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
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar",
                  style: TextStyle(color: Colors.white70)),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx);
                  await _updateUserField(
                    column: column,
                    value: controller.text.trim(),
                  );
                }
              },
              child: const Text("Salvar"),
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
    }
    if (d.length == 10) {
      return '(${d.substring(0, 2)}) ${d.substring(2, 6)}-${d.substring(6)}';
    }
    return v;
  }

 

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _lockedTheme,
      child: Scaffold(
        appBar: AppBar(title: const Text("Meu Perfil")),
        body: FutureBuilder<Map<String, dynamic>?>(
          future: _profileFuture,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: kCardBg),
              );
            }

            final data = snap.data!;
            final nome = data["nome"] ?? "";
            final email = data["email"] ?? "";
            final cpf = data["cpf"] ?? "";
            final telefone = data["telefone"] ?? "";
            final cep = data["cep"] ?? "";
            final fotoUrl = data["foto_url"] ?? "";

            return RefreshIndicator(
              onRefresh: () async {
                _recarregarPerfil();
                await _profileFuture;
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 12),

                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: kCardBg,

                  
                          backgroundImage: fotoUrl.isNotEmpty
                              ? NetworkImage(
                                  "$fotoUrl&t=${DateTime.now().millisecondsSinceEpoch}")
                              : null,

                          child: fotoUrl.isEmpty
                              ? Text(
                                  nome.isNotEmpty
                                      ? nome[0].toUpperCase()
                                      : "?",
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: InkWell(
                            onTap: _selecionarImagem,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: kCardBg,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black54),
                              ),
                              child: const Icon(Icons.camera_alt,
                                  size: 20, color: Colors.black87),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Center(
                    child: Text(
                      nome.isEmpty ? "Usuário" : nome,
                      style: const TextStyle(
                        color: kTextMain,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const _SectionTitle("Informações pessoais"),

                  _InfoTileEditable(
                    icon: Icons.badge_outlined,
                    label: "Nome",
                    value: nome,
                    onEdit: () => _openEditDialog(
                      titulo: "Editar nome",
                      column: "nome",
                      initialValue: nome,
                      validator: (v) =>
                          v == null || v.isEmpty ? "Preencha este campo" : null,
                    ),
                  ),

                  _InfoTileEditable(
                    icon: Icons.email_outlined,
                    label: "E-mail",
                    value: email,
                    onEdit: () => _openEditDialog(
                      titulo: "Editar e-mail",
                      column: "email",
                      initialValue: email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),

         
                  Card(
                    color: kCardBg,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.credit_card, color: kBgNavy),
                      title: const Text(
                        "CPF",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        _maskCPF(cpf),
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),

                  _InfoTileEditable(
                    icon: Icons.phone_outlined,
                    label: "Telefone",
                    value: _maskPhoneBR(telefone),
                    onEdit: () => _openEditDialog(
                      titulo: "Editar telefone",
                      column: "telefone",
                      initialValue: telefone,
                      keyboardType: TextInputType.phone,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const _SectionTitle("Endereço"),

                  _InfoTileEditable(
                    icon: Icons.location_on_outlined,
                    label: "CEP",
                    value: _maskCEP(cep),
                    onEdit: () => _openEditDialog(
                      titulo: "Editar CEP",
                      column: "cep",
                      initialValue: cep,
                      keyboardType: TextInputType.number,
                    ),
                  ),

                  const SizedBox(height: 32),

                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kTextMain,
                      side:
                          BorderSide(color: kTextMain.withOpacity(0.7)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      await _supabase.auth.signOut();
                      if (!mounted) return;
                      _goToLogin();
                    },
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text("Sair"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

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

class _InfoTileEditable extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onEdit;

  const _InfoTileEditable({
    required this.icon,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kCardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
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
          value.isEmpty ? "-" : value,
          style: const TextStyle(color: Colors.black87),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.black87),
          onPressed: onEdit,
          tooltip: "Editar",
        ),
      ),
    );
  }
}