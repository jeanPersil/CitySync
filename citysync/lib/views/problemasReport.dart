import 'package:flutter/material.dart';

class Problemasreport extends StatelessWidget {
  const Problemasreport({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.5;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Row(
          children: [
            Icon(Icons.people_alt_outlined, color: colorScheme.onPrimary),
            const SizedBox(width: 8),
            Text(
              "Sylas",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            Container(
              width: containerWidth,
              height: MediaQuery.of(context).size.height * 0.59,
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: colorScheme.background,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              color: colorScheme.secondary.withOpacity(0.7),
                              child: const Text(
                                "Cano estourado",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    padding: const EdgeInsets.all(8.0),
                                    color: colorScheme.secondary.withOpacity(0.9),
                                    child: const Center(
                                      child: Text(
                                        "TEMPO DECORRIDO: 15H",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.all(8.0),
                                    color: colorScheme.secondary.withOpacity(0.9),
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
          ],
        ),
      ),
    );
  }
}
