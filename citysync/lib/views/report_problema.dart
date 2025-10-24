import 'dart:typed_data';
import 'dart:io' as io show File;

import 'package:citysync/services/reports.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:citysync/Tema/color_extension.dart';
import 'package:geocoding/geocoding.dart'; // Adicione este pacote

class TelaReport extends StatefulWidget {
  const TelaReport(
      {super.key, required this.usuarioId, required this.categoria});

  final String usuarioId;
  final String categoria;

  @override
  TelaReportState createState() => TelaReportState();
}

class TelaReportState extends State<TelaReport> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController problemController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final LatLng _initialPosicao = LatLng(-12.2664, -38.9668);
  
  // Controlador do mapa
  GoogleMapController? _mapController;
  
  // Marcador no mapa
  Set<Marker> _markers = {};
  
  // Posição atual do mapa
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    problemController.text = widget.categoria;
    
    // Adicionar listener para o campo de endereço
    addressController.addListener(_onAddressChanged);
    
    // Marcador inicial na posição padrão
    _addMarker(_initialPosicao, "Posição Inicial");
    _currentPosition = _initialPosicao;
  }

  @override
  void dispose() {
    addressController.removeListener(_onAddressChanged);
    super.dispose();
  }

  Uint8List? imageBytes;
  io.File? imageFile;
  String? imageName;

  // Listener para mudanças no campo de endereço
  void _onAddressChanged() {
    // Usar um delay para não fazer muitas requisições enquanto o usuário digita
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (addressController.text.isNotEmpty) {
        _geocodeAddress(addressController.text);
      }
    });
  }

  // Função para converter endereço em coordenadas
  Future<void> _geocodeAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        Location location = locations.first;
        LatLng newPosition = LatLng(location.latitude, location.longitude);
        
        setState(() {
          _currentPosition = newPosition;
          _markers.clear();
          _addMarker(newPosition, address);
        });
        
        // Animar a câmera para a nova posição
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newPosition, 16),
        );
      }
    } catch (e) {
      print("Erro ao geocodificar endereço: $e");
      // Você pode mostrar um snackbar ou tratar o erro de outra forma
    }
  }

  // Função para adicionar marcador
  void _addMarker(LatLng position, String title) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId(title),
          position: position,
          infoWindow: InfoWindow(title: title),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  Future<void> pickImage() async {
    if (kIsWeb) {
      // Web
      print("testando");
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

  int mapearCategoriaId(String nome) {
    switch (nome.toLowerCase()) {
      case 'buraco':
        return 1;
      case 'iluminação':
        return 2;
      case 'lixo':
        return 3;
      case 'semafaro':
        return 4;
      case 'vazamento/esgoto':
        return 5;
      case 'transporte':
        return 6;
      case 'outros':
        return 7;
      default:
        return 0;
    }
  }

  void _abrirVisualizacaoImagem() {
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacidade(0.9),
          body: Stack(
            children: [
              Center(
                child:
                    kIsWeb ? Image.memory(imageBytes!) : Image.file(imageFile!),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacidade(0.5),
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
    if (addressController.text.isNotEmpty &&
        problemController.text.isNotEmpty) {
      final resultado = await ReportApiService().enviarReport(
        endereco: addressController.text,
        categoriaId: mapearCategoriaId(widget.categoria),
        usuarioId: widget.usuarioId,
        descricao: descriptionController.text,
        urlImagem: imageName,
      );

      if (resultado == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Seu problema foi reportado!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $resultado")),
        );
      }
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition ?? _initialPosicao,
                    zoom: 16,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: _markers,
                  onTap: (LatLng position) {
                    // Opcional: permitir que o usuário clique no mapa para selecionar localização
                    _handleMapTap(position);
                  },
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor:
                        isDark ? Colors.grey[700] : Colors.grey[300],
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
                            backgroundColor:
                                isDark ? Colors.grey[800] : Colors.white,
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

  // Função opcional para permitir seleção pelo mapa
  void _handleMapTap(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String address = "${placemark.street}, ${placemark.locality}";
        
        setState(() {
          addressController.text = address;
          _currentPosition = position;
          _markers.clear();
          _addMarker(position, address);
        });
        
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(position, 16),
        );
      }
    } catch (e) {
      print("Erro ao obter endereço: $e");
    }
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