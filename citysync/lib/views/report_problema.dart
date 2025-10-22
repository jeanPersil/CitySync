import 'dart:typed_data';
import 'dart:io' as io show File;

import 'package:citysync/services/reports.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class TelaReport extends StatefulWidget {
  const TelaReport({
    super.key, 
    required this.usuarioId, 
    required this.categoria,
    required this.selectedLocation,
    required this.selectedAddress,
  });

  final String usuarioId;
  final String categoria;
  final LatLng selectedLocation;
  final String selectedAddress;

  @override
  TelaReportState createState() => TelaReportState();
}

class TelaReportState extends State<TelaReport> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController problemController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  late LatLng _currentLocation;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.selectedLocation;
    addressController.text = widget.selectedAddress;
    problemController.text = widget.categoria;
  }

  Uint8List? imageBytes;
  io.File? imageFile;
  String? imageName;

  Future<void> pickImage() async {
    try {
      if (kIsWeb) {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          if (!mounted) return;
          setState(() {
            imageBytes = bytes;
            imageName = pickedFile.name;
          });
        }
      } else {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.camera);

        if (pickedFile != null) {
          if (!mounted) return;
          setState(() {
            imageFile = io.File(pickedFile.path);
            imageName = pickedFile.name;
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao selecionar imagem: $e');
    }
  }

  int mapearCategoriaId(String nome) {
    switch (nome.toLowerCase()) {
      case 'buraco': return 1;
      case 'iluminação': return 2;
      case 'lixo': return 3;
      case 'semafaro': return 4;
      case 'vazamento/esgoto': return 5;
      case 'transporte': return 6;
      case 'outros': return 7;
      default: return 0;
    }
  }

  void _abrirVisualizacaoImagem() {
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.black.withValues(alpha: 0.9),
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
                      color: Colors.white.withValues(alpha: 0.5),
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

  void _reportarProblema() async {
    if (addressController.text.isEmpty || problemController.text.isEmpty) {
      _showErrorSnackBar('Por favor, preencha todos os campos obrigatórios.');
      return;
    }

    try {
      final resultado = await ReportApiService().enviarReport(
        endereco: addressController.text,
        categoriaId: mapearCategoriaId(widget.categoria),
        usuarioId: widget.usuarioId,
        descricao: descriptionController.text,
        urlImagem: imageName,
      );

      if (!mounted) return;

      if (resultado == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Seu problema foi reportado!")),
        );
      } else {
        _showErrorSnackBar("Erro: $resultado");
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao reportar problema: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _cancelarReport() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final panelHeight = screenHeight * 0.6;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation,
                    zoom: 16,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('problem_location'),
                      position: _currentLocation,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    ),
                  },
                  onMapCreated: (controller) {},
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                    child: Icon(Icons.person,
                        color: isDark ? Colors.black : Colors.white),
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
              color: isDark ? Colors.grey[900] : const Color(0xFF1E3A5F),
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
                  _buildTextField(problemController, "EX: Buraco", isDark,
                      readOnly: true),
                  _buildSectionTitle("Descrição (opcional)", isDark),
                  _buildTextField(
                      descriptionController, "Descreva o problema...", isDark),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: isDark ? Colors.white : Colors.black,
                            size: 30,
                          ),
                          if (imageName != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Imagem salva: ${imageName!.length > 15 ? '${imageName!.substring(0, 12)}...' : imageName}',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  imageBytes = null;
                                  imageFile = null;
                                  imageName = null;
                                });
                              },
                              child: Icon(
                                Icons.close,
                                color: isDark ? Colors.redAccent : Colors.red,
                                size: 20,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (imageName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ElevatedButton(
                        onPressed: _abrirVisualizacaoImagem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text("Visualizar Imagem"),
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
                              side: BorderSide(
                                  color: isDark ? Colors.white30 : Colors.grey),
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
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool isDark, {
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
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