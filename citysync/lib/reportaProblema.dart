import 'package:citysync/homePage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReportProblemPage extends StatefulWidget {
  @override
  _ReportProblemPageState createState() => _ReportProblemPageState();
}

class _ReportProblemPageState extends State<ReportProblemPage> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController problemController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  final LatLng _initialPosition = LatLng(-12.2664, -38.9668);
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[900],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: Colors.blue[900]),
                        ),
                        const SizedBox(width: 10),
                        const Text('IWIN', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _initialPosition,
                          zoom: 16,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        onTap: (LatLng position) {
                          print('Local selecionado: $position');
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionTitle('Endereço Selecionado'),
                        _buildTextField(addressController, 'Digite o endereço'),

                        _buildSectionTitle('Qual problema gostaria de relatar?'),
                        _buildTextField(problemController, 'Descreva o problema'),

                        _buildSectionTitle('A quanto tempo ocorre?'),
                        _buildTextField(timeController, 'Ex: 15 horas'),

                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: const Icon(Icons.image, size: 50, color: Colors.white),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                print('Endereço: ${addressController.text}');
                                print('Problema: ${problemController.text}');
                                print('Tempo: ${timeController.text}');

                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Sucesso'),
                                    content: const Text('Seu relatório foi enviado com sucesso!'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.touch_app),
                              label: const Text('REPORTAR'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                addressController.clear();
                                problemController.clear();
                                timeController.clear();
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => Homepage()),
                                );
                              },
                              child: const Text('CANCELAR'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                side: const BorderSide(color: Colors.grey),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

 Widget _buildSectionTitle(String title) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;
      double fieldWidth = maxWidth > 600 ? maxWidth * 0.7 : maxWidth;

      return Center(
        child: Container(
          width: fieldWidth,
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      );
    },
  );
}


 Widget _buildTextField(TextEditingController controller, String hint) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;
      double fieldWidth = maxWidth > 500 ? maxWidth * 0.6 : maxWidth;

      return Center(
        child: Container(
          width: fieldWidth,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
          ),
        ),
      );
    },
  );
}
}
