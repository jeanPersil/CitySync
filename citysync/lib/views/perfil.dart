import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:citysync/views/login.dart';

// Constantes
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
  final SupabaseClient _supabase = Supabase.instance.client;
  late Future<Map<String, dynamic>?> _profileFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profileFuture = _fetchProfile();
  }

  Future<Map<String, dynamic>?> _fetchProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await _supabase
          .from('users')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      return data == null ? null : Map<String, dynamic>.from(data);
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao carregar perfil: $e');
      }
      return null;
    }
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const TelaLogin()),
      (route) => false,
    );
  }

  Future<void> _updateUserField({
    required String column,
    required String value,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // Atualiza email no Auth se for o caso
      if (column == 'email') {
        await _supabase.auth.updateUser(UserAttributes(email: value));
      }

      // Atualiza no banco de dados
      final updated = await _supabase
          .from('users')
          .update({column: value})
          .eq('id', user.id)
          .select()
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        _profileFuture = Future.value(
          updated == null ? null : Map<String, dynamic>.from(updated),
        );
      });

      _showSnackBar('Informação atualizada com sucesso!');
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao atualizar: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('Erro') ? Colors.redAccent : Colors.green,
      ),
    );
  }

  Future<void> _openEditDialog({
    required String title,
    required String column,
    required String initialValue,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kDialogBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.edit, color: kTextMain),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: kTextMain,
                fontWeight: FontWeight.w700,
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
            decoration: InputDecoration(
              labelText: 'Novo valor',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withValues( alpha: 0.5)),
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
              fillColor: Colors.white.withValues( alpha: 0.10),
            ),
            validator: validator,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white.withValues( alpha: 0.15),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                _updateUserField(
                  column: column,
                  value: controller.text.trim(),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  // Métodos de máscara
  String _maskCPF(String? value) {
    if (value == null) return '';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) return value;
    return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9)}';
  }

  String _maskCEP(String? value) {
    if (value == null) return '';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return value;
    return '${digits.substring(0, 5)}-${digits.substring(5)}';
  }

  String _maskPhoneBR(String? value) {
    if (value == null) return '';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
    } else if (digits.length == 10) {
      return '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
    }
    return value;
  }

  // Métodos de validação
  String? _validateNotEmpty(String? value) => 
      (value == null || value.trim().isEmpty) ? 'Preencha este campo' : null;

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Preencha o e-mail';
    final isValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
    return isValid ? null : 'E-mail inválido';
  }

  String? _validateCPF(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    return digits.length == 11 ? null : 'CPF deve ter 11 dígitos';
  }

  String? _validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    return (digits.length == 10 || digits.length == 11) ? null : 'Telefone deve ter 10-11 dígitos';
  }

  String? _validateCEP(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    return digits.length == 8 ? null : 'CEP deve ter 8 dígitos';
  }

  Future<void> _handleSignOut() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    await _supabase.auth.signOut();
    
    if (mounted) {
      setState(() => _isLoading = false);
      _goToLogin();
    }
  }

  Future<void> _handleRefresh() async {
    if (_isLoading) return;
    setState(() => _loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgNavy,
      appBar: AppBar(
        backgroundColor: kBgNavy,
        foregroundColor: kTextMain,
        title: const Text('Meu Perfil'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: kCardBg),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return _buildErrorState();
          }

          return _buildProfileContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Não foi possível carregar o perfil.',
            style: TextStyle(color: kTextMain),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _handleRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: kCardBg,
              foregroundColor: kBgNavy,
            ),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(Map<String, dynamic> data) {
    final nome = (data['nome'] ?? '') as String;
    final email = (data['email'] ?? '') as String;
    final cpf = (data['cpf'] ?? '') as String;
    final telefone = (data['telefone'] ?? '') as String;
    final cep = (data['cep'] ?? '') as String;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: kCardBg,
      backgroundColor: kBgNavy,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(nome),
          const SizedBox(height: 24),
          _buildPersonalInfoSection(nome, email, cpf, telefone),
          const SizedBox(height: 20),
          _buildAddressSection(cep),
          const SizedBox(height: 32),
          _buildSignOutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(String nome) {
    return Column(
      children: [
        const SizedBox(height: 12),
        CircleAvatar(
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
        const SizedBox(height: 12),
        Text(
          nome.isEmpty ? 'Usuário' : nome,
          style: const TextStyle(
            color: kTextMain,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection(
    String nome,
    String email,
    String cpf,
    String telefone,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Informações pessoais'),
        InfoTileEditable(
          icon: Icons.badge_outlined,
          label: 'Nome',
          value: nome,
          onEdit: () => _openEditDialog(
            title: 'Editar nome',
            column: 'nome',
            initialValue: nome,
            validator: _validateNotEmpty,
          ),
        ),
        InfoTileEditable(
          icon: Icons.email_outlined,
          label: 'E-mail',
          value: email,
          onEdit: () => _openEditDialog(
            title: 'Editar e-mail',
            column: 'email',
            initialValue: email,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
        ),
        InfoTileEditable(
          icon: Icons.credit_card,
          label: 'CPF',
          value: _maskCPF(cpf),
          onEdit: () => _openEditDialog(
            title: 'Editar CPF',
            column: 'cpf',
            initialValue: cpf,
            keyboardType: TextInputType.number,
            validator: _validateCPF,
          ),
        ),
        InfoTileEditable(
          icon: Icons.phone_outlined,
          label: 'Telefone',
          value: _maskPhoneBR(telefone),
          onEdit: () => _openEditDialog(
            title: 'Editar telefone',
            column: 'telefone',
            initialValue: telefone,
            keyboardType: TextInputType.phone,
            validator: _validatePhone,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection(String cep) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Endereço'),
        InfoTileEditable(
          icon: Icons.location_on_outlined,
          label: 'CEP',
          value: _maskCEP(cep),
          onEdit: () => _openEditDialog(
            title: 'Editar CEP',
            column: 'cep',
            initialValue: cep,
            keyboardType: TextInputType.number,
            validator: _validateCEP,
          ),
        ),
      ],
    );
  }

  Widget _buildSignOutButton() {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: kTextMain,
        side: BorderSide(color: kTextMain.withValues( alpha: 0.7)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: _isLoading ? null : _handleSignOut,
      icon: _isLoading 
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: kTextMain,
              ),
            )
          : const Icon(Icons.exit_to_app),
      label: _isLoading ? const Text('Saindo...') : const Text('Sair'),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

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

class InfoTileEditable extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onEdit;

  const InfoTileEditable({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
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
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.black87),
          onPressed: onEdit,
          tooltip: 'Editar',
        ),
      ),
    );
  }
}