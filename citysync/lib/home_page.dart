import 'package:citysync/views/config.dart';
import 'package:citysync/views/lista_problemas_report.dart';
import 'package:citysync/views/tela_principal.dart';
import 'package:flutter/material.dart';
import 'Tema/color_extension.dart';

class Homepage extends StatefulWidget {
  Homepage({super.key, required this.usuarioNome, required this.usuarioID});

  final String usuarioNome;
  final int usuarioID;

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int paginaAtual = 0;
  late PageController pc;

  @override
  void initState() {
    super.initState();
    pc = PageController(initialPage: paginaAtual);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final backgroundColor =
        brightness == Brightness.light ? Colors.blue : Colors.grey[900];

    return Scaffold(
      body: PageView(
        controller: pc,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Telaprincipal(
            nomeUsuario: widget.usuarioNome,
            usuarioID: widget.usuarioID,
          ),
          ProblemasReport(
            nomeUsuario: widget.usuarioNome,
            usuarioID: widget.usuarioID,
          ),
          const TelaConfig(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: paginaAtual,
        backgroundColor: backgroundColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacidade(0.7),
        selectedLabelStyle: const TextStyle(color: Colors.white),
        unselectedLabelStyle: TextStyle(color: Colors.white.withOpacidade(0.7)),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem_sharp),
            label: "Problemas report",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Configurações",
          ),
        ],
        onTap: (pagina) {
          setState(() {
            paginaAtual = pagina;
          });
          pc.animateToPage(
            pagina,
            duration: const Duration(milliseconds: 400),
            curve: Curves.ease,
          );
        },
      ),
    );
  }
}
