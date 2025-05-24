import 'package:flutter/material.dart';

class Problemasreport extends StatelessWidget {
  const Problemasreport({super.key});

  @override
  Widget build(BuildContext context) {
    
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth * 0.5; // Container principal com 50% da width

    return Scaffold(
      // Hotbar superior de perfil
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: const [
            Icon(
              Icons.people_alt_outlined,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              "Sylas",
              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
      ),
      // Corpo centralizado com retângulo de título e container principal dos reports
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Retângulo de título
            Container(
              width: containerWidth,
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.lightBlue[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "TELA DE REPORTES FEITO PELO USUARIO",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // Container principal que abriga os reports
            Container(
              width: containerWidth,
              height: MediaQuery.of(context).size.height * 0.59,
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8.0),
              // Lista de reports
              child: ListView.builder(
                itemCount: 10, // Ajustar conforme a quantidade de reports
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Retângulo descritivo com o nome do problema
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              color: Colors.lightBlue[200],
                              child: const Text(
                                "Cano estourado",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Container dividido em tempo e quantidade
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                // Retângulo de tempo
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    padding: const EdgeInsets.all(8.0),
                                    color: Colors.lightBlue[300],
                                    child: const Center(
                                      child: Text(
                                        "TEMPO DECORRIDO: 15H",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ),
                                // Retângulo de quantidade
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.all(8.0),
                                    color: Colors.lightBlue[300],
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
