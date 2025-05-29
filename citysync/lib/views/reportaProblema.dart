import 'dart:typed_data';
import 'dart:io' as io show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';

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

  Uint8List? imageBytes;
  io.File? imageFile;
  String? imageName;

  Future<void> pickImage() async {
    if (kIsWeb) {
      // Web
      final media = await ImagePickerWeb.getImageInfo;
      if (media != null) {
        setState(() {
          imageBytes = media.data;
          imageName = media.fileName ?? 'imagem_web.png';
        });
      }
    } else {
      // Mobile
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          imageFile = io.File(pickedFile.path);
          imageName = pickedFile.name;
        });
      }
    }
  }

  void _abrirVisualizacaoImagem() {
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.9),
          body: Stack(
            children: [
              Center(
                child: kIsWeb
                    ? Image.memory(imageBytes!)
                    : Image.file(imageFile!),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 28,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _reportarProblema() {
    if (addressController.text.isNotEmpty &&
        problemController.text.isNotEmpty &&
        timeController.text.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Sucesso"),
            content: const Text("Seu problema foi reportado!"),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
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

    return Scaffold(
      body: Column(
        children: [
          // MAPA NA PARTE DE CIMA
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
                // ÍCONE NO CANTO SUPERIOR DO MAPA
                Positioned(
                  top: 16,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // PARTE AZUL EM BAIXO
          Container(
            width: double.infinity,
            height: panelHeight,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSectionTitle("Endereço selecionado:"),
                  _buildTextField(addressController, "EX: Senai - FSA"),
                  _buildSectionTitle("Problema relatado"),
                  _buildTextField(problemController, "EX: Buraco"),
                  _buildSectionTitle("A quanto tempo ocorre?"),
                  _buildTextField(timeController, "EX: 2 horas"),
                  _buildSectionTitle("Descrição (opcional)"),
                  _buildTextField(descriptionController, "Descreva o problema com mais detalhes..."),
                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: pickImage, // Tocar aqui para tirar ou selecionar uma nova imagem
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.black, size: 30),
                    ),
                  ),

                  // --- NOVO BOTÃO DE VISUALIZAÇÃO AQUI ---
                  if (imageName != null) // Só mostra o botão se houver uma imagem salva
                    Padding(
                      padding: const EdgeInsets.only(top: 10), // Adiciona um pequeno espaçamento
                      child: ElevatedButton(
                        onPressed: _abrirVisualizacaoImagem, // Chama sua função de visualização
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Cor do botão
                          foregroundColor: Colors.black, // Cor do texto do botão
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text("Visualizar Imagem"),
                      ),
                    ),

                  const SizedBox(height: 20),

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
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Colors.grey),
                            ),
                          ),
                          child: const Text(
                            "Cancelar",
                            style: TextStyle(color: Colors.black, fontSize: 14),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          filled: false,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}