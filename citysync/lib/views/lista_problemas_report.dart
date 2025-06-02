// problemas_report.dart
import 'package:flutter/material.dart';
import 'package:citysync/Tema/color_extension.dart';

class ProblemasReport  extends StatelessWidget {
  const ProblemasReport ({super.key});

  // Simulação de "dados vindo do Banco de dados"
  final List<String> prioridades = const [
    "Alta",
    "Baixa",
    "Mediana",
    "Alta",
    "Baixa",
    "Mediana",
    "Alta",
    "Baixa",
    "Mediana",
    "Alta",
  ];

  // Função que converte o texto “prioridade” em cor
  Color corPorPrioridade(ColorScheme cs, String prioridade) {
    switch (prioridade) {
      case "Alta":
        return Colors.red.withOpacidade(0.6);
      case "Mediana":
        return Colors.yellow.withOpacidade(0.6);
      case "Baixa":
        return Colors.green.withOpacidade(0.6);
      default:
        // fallback
        return cs.secondary.withOpacidade(0.6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth =
        (screenWidth < 600) ? screenWidth * 0.9 : screenWidth * 0.5;

    final horizontalPadding = (screenWidth < 600) ? 16.0 : (screenWidth - containerWidth) / 2;
    final colorScheme = Theme.of(context).colorScheme;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.lightBlue.withOpacidade(0.4),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[850] : Colors.blue,
        title: Row(
          children: [
            Icon(Icons.people_alt_outlined, color: isDark ? Colors.white : Colors.white),
            const SizedBox(width: 8),
            Text(
              "Sylas",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(
              width: containerWidth,
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withOpacidade(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "TELA DE REPORTES FEITO PELO USUARIO",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Box de listagem(ListView)

            Flexible(
              child: Container(
                width: containerWidth,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacidade(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    
                    final prioridadeAtual = prioridades[index];
                    final corFundo = corPorPrioridade(colorScheme, prioridadeAtual);

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: corFundo,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IntrinsicHeight(

                         // “Box Problema/Descrição” 
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                color: corFundo.withOpacidade(0.6),
                                child: const Text(
                                  "Cano estourado",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Sub‐container “Tempo Decorrido”
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.all(8),
                                      color: corFundo.withOpacidade(0.6),
                                      child: const Center(
                                        child: Text(
                                          "TEMPO DECORRIDO: 15H",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Sub-container “Total Reportes”
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.all(8),
                                      color: corFundo.withOpacidade(0.6),
                                      child: const Center(
                                        child: Text(
                                          "TOTAL REPORTES: 15",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
