import 'package:citysync/model/modelReport.dart';
import 'package:citysync/services/reports.dart';
import 'package:citysync/widgets/cardProblema.dart';
import 'package:flutter/material.dart';

class ProblemasReport extends StatelessWidget {
  ProblemasReport({
    super.key,
    required this.nomeUsuario,
    required this.usuarioID,
  });

  final ReportApiService reportApiService = ReportApiService();
  final String nomeUsuario;
  final int usuarioID;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth =
        (screenWidth < 600) ? screenWidth * 0.9 : screenWidth * 0.5;
    final horizontalPadding =
        (screenWidth < 600) ? 16.0 : (screenWidth - containerWidth) / 2;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: isDark
          ? Colors.grey[900]
          : const Color.fromARGB(255, 3, 115, 244).withOpacity(0.4),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[850] : Color(0xFF1E3A5F),
        title: Row(
          children: [
            Icon(Icons.people_alt_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              nomeUsuario,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Colors.white),
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
                color: colorScheme.secondary.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "TELA DE REPORTES FEITO PELO USUARIO",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            /// Lista de reports
            Expanded(
              child: FutureBuilder<List<Report>>(
                future: reportApiService.obterListaReports(usuarioID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Erro: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text("Nenhum problema reportado."));
                  }

                  final reports = snapshot.data!;
                  return ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return CardPRoblema(
                          report: report); // nome correto da classe
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
