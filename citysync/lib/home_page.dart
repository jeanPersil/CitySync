import 'package:citysync/views/config.dart';
import 'package:citysync/views/lista_problemas_report.dart';
import 'package:citysync/views/tela_principal.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _paginaAtual = 0;
  late final PageController _pageController;
  String? _usuarioNome;
  String? _usuarioID;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _loadUserData();
  }

  void _initializeController() {
    _pageController = PageController(initialPage: _paginaAtual);
  }

  void _loadUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user != null) {
      _usuarioID = user.id;
      _usuarioNome = user.email;
    } else {
      // Fallback values caso não tenha usuário (deveria ser raro)
      _usuarioID = 'unknown';
      _usuarioNome = 'Usuário';
    }
  }

  void _onPageChanged(int pagina) {
    setState(() {
      _paginaAtual = pagina;
    });
    _pageController.animateToPage(
      pagina,
      duration: const Duration(milliseconds: 400),
      curve: Curves.ease,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = _getBackgroundColor(context);

    return Scaffold(
      body: _buildPageView(),
      bottomNavigationBar: _buildBottomNavigationBar(backgroundColor),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light 
        ? const Color(0xFF1E3A5F) 
        : Colors.grey[900]!;
  }

  Widget _buildPageView() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: _onPageChanged,
      children: [
        if (_usuarioNome != null && _usuarioID != null) ...[
          Telaprincipal(
            nomeUsuario: _usuarioNome!,
            usuarioID: _usuarioID!,
          ),
          ProblemasReport(
            nomeUsuario: _usuarioNome!,
            usuarioID: _usuarioID!,
          ),
          const TelaConfig(),
        ] else ...[
          _buildLoadingScreen(),
          _buildLoadingScreen(),
          _buildLoadingScreen(),
        ],
      ],
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildBottomNavigationBar(Color backgroundColor) {
    return BottomNavigationBar(
      currentIndex: _paginaAtual,
      backgroundColor: backgroundColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withValues(alpha: 0.7),
      selectedLabelStyle: const TextStyle(color: Colors.white),
      unselectedLabelStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.7),
      ),
      type: BottomNavigationBarType.fixed, // Melhor para 3+ items
      items: _buildNavigationItems(),
      onTap: _onPageChanged,
    );
  }

  List<BottomNavigationBarItem> _buildNavigationItems() {
    return const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: "Home",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.report_problem_sharp),
        label: "Meus Reports",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: "Configurações",
      ),
    ];
  }
}