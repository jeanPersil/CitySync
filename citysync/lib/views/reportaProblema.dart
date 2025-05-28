import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class tela_report extends StatefulWidget {
  @override
  _tela_report_State createState() => _tela_report_State();
}

class _tela_report_State extends State<tela_report> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController problemController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final LatLng _initialPosicao = LatLng(-12.2664, -38.9668);
  GoogleMapController? _mapController;

  void _reportarProblema() {
    if (addressController.text.isNotEmpty &&
        problemController.text.isNotEmpty &&
        timeController.text.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Sucesso"),
            content: const Text("Seu problema foi reportado!"),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _cancelarReport() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final panelHeight = screenHeight * 0.6;

    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialPosicao,
                    zoom: 16,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
                Positioned(
                  top: 16.0,
                  left: 16.0,
                  child: CircleAvatar(
                    backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: panelHeight,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.blue,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSectionTitle("Endereço selecionado:", isDark),
                  _buildTextField(addressController, "EX: Senai - FSA", isDark),
                  _buildSectionTitle("Problema relatado", isDark),
                  _buildTextField(problemController, "EX: Buraco", isDark),
                  _buildSectionTitle("A quanto tempo ocorre?", isDark),
                  _buildTextField(timeController, "EX: 2 horas", isDark),
                  _buildSectionTitle("Descrição (opcional)", isDark),
                  _buildTextField(descriptionController, "Descreva o problema com mais detalhes...", isDark),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: isDark ? Colors.white : Colors.black,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 35,
                        child: ElevatedButton(
                          onPressed: _reportarProblema,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            "Reportar",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 35,
                        child: ElevatedButton(
                          onPressed: _cancelarReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: isDark ? Colors.white30 : Colors.grey),
                            ),
                          ),
                          child: Text(
                            "Cancelar",
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: TextStyle(color: isDark ? Colors.black : Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: isDark ? Colors.black54 : Colors.white70),
          filled: false,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: isDark ? Colors.black : Colors.white),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: isDark ? Colors.black : Colors.white),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
