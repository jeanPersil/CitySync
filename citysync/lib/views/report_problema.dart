import 'dart:typed_data';
import 'dart:io' as io show File;
import 'dart:convert';
import 'dart:async';

import 'package:citysync/services/reports.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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
  LatLng _posicaoSelecionada = LatLng(-12.2664, -38.9668);
  
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isUpdatingFromMap = false;
  bool _isUpdatingFromTextField = false;

  // Google API Key do projeto
  static const String _googleApiKey = "AIzaSyBuuPoXMIcbCOMSgIzTnHENU9jzfzb22nc";

  @override
  void initState() {
    super.initState();
    problemController.text = widget.categoria;
    _posicaoSelecionada = _initialPosicao;
    _adicionarMarcador(_initialPosicao);
  }

  Uint8List? imageBytes;
  io.File? imageFile;
  String? imageName;

  // Adiciona ou atualiza o marcador no mapa
  void _adicionarMarcador(LatLng posicao) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('local_selecionado'),
          position: posicao,
          draggable: true,
          onDragEnd: (novaPosicao) {
            _atualizarPosicao(novaPosicao);
          },
        ),
      );
    });
  }

  // Atualiza a posição e busca o endereço
  void _atualizarPosicao(LatLng novaPosicao) async {
    setState(() {
      _posicaoSelecionada = novaPosicao;
      _isUpdatingFromMap = true;
    });
    
    _adicionarMarcador(novaPosicao);
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(novaPosicao),
    );

    // Busca o endereço da posição usando a API do Google
    try {
      // Verifica se a API key está configurada
      if (_googleApiKey == "SUA_API_KEY_AQUI" || _googleApiKey.isEmpty) {
        print("⚠️ API Key não configurada! Configure a chave na constante _googleApiKey");
        addressController.text = "Lat: ${novaPosicao.latitude.toStringAsFixed(6)}, Lng: ${novaPosicao.longitude.toStringAsFixed(6)}";
        _isUpdatingFromMap = false;
        return;
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${novaPosicao.latitude},${novaPosicao.longitude}&key=$_googleApiKey&language=pt-BR'
      );
      
      print("🔍 Buscando endereço para: ${novaPosicao.latitude}, ${novaPosicao.longitude}");
      
      final response = await http.get(url);
      
      print("📡 Status da resposta: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("📦 Resposta da API: ${data['status']}");
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          String endereco = data['results'][0]['formatted_address'];
          endereco = endereco.replaceAll(', Brasil', '');
          
          print("✅ Endereço encontrado: $endereco");
          addressController.text = endereco;
        } else if (data['status'] == 'REQUEST_DENIED') {
          print("❌ API Key inválida ou sem permissão para Geocoding API");
          addressController.text = "Erro: API Key inválida";
        } else if (data['status'] == 'ZERO_RESULTS') {
          print("⚠️ Nenhum endereço encontrado para esta localização");
          addressController.text = "Lat: ${novaPosicao.latitude.toStringAsFixed(6)}, Lng: ${novaPosicao.longitude.toStringAsFixed(6)}";
        } else {
          throw Exception('Status: ${data['status']}');
        }
      } else {
        throw Exception('Erro HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Erro ao buscar endereço: $e");
      addressController.text = "Lat: ${novaPosicao.latitude.toStringAsFixed(6)}, Lng: ${novaPosicao.longitude.toStringAsFixed(6)}";
    } finally {
      _isUpdatingFromMap = false;
    }
  }

  // Busca coordenadas a partir do endereço digitado
  void _buscarLocalizacaoPorEndereco(String endereco) async {
    if (endereco.isEmpty || _isUpdatingFromMap || endereco.length < 3) return;
    
    setState(() {
      _isUpdatingFromTextField = true;
    });

    try {
      String enderecoCompleto = endereco;
      if (!endereco.toLowerCase().contains('feira de santana')) {
        enderecoCompleto = "$endereco, Feira de Santana, BA, Brasil";
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(enderecoCompleto)}&key=$_googleApiKey&language=pt-BR'
      );
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          LatLng novaPosicao = LatLng(location['lat'], location['lng']);
          
          setState(() {
            _posicaoSelecionada = novaPosicao;
          });
          
          _adicionarMarcador(novaPosicao);
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(novaPosicao, 16),
          );
        }
      }
    } catch (e) {
      print("Erro ao buscar localização: $e");
    } finally {
      _isUpdatingFromTextField = false;
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    
    if (kIsWeb) {
      
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          imageBytes = bytes;
          imageName = pickedFile.name;
          imageFile = null; 
        });
      }
    } else {
     
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          imageFile = io.File(pickedFile.path);
          imageName = pickedFile.name;
          imageBytes = null; 
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
          backgroundColor: Colors.black.withOpacity(0.9),
          body: Stack(
            children: [
              Center(
                child: kIsWeb ? Image.memory(imageBytes!) : Image.file(imageFile!),
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

  void _reportarProblema() async {
  if (addressController.text.isNotEmpty &&
      problemController.text.isNotEmpty) {
    
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    String? urlImagem;

    // Fazer upload da imagem ANTES de enviar o report
    if (imageName != null) {
      urlImagem = await ReportApiService().uploadImagem(
        imageFile: imageFile,
        imageBytes: imageBytes,
        imageName: imageName!,
      );

      if (urlImagem == null) {
        Navigator.of(context).pop(); // Fechar loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao fazer upload da imagem")),
        );
        return;
      }
    }

    // Enviar o report com a URL da imagem
    final resultado = await ReportApiService().enviarReport(
      endereco: addressController.text,
      categoriaId: mapearCategoriaId(widget.categoria),
      usuarioId: widget.usuarioId,
      descricao: descriptionController.text,
      urlImagem: urlImagem, 
      latitude: _posicaoSelecionada.latitude,
      longitude: _posicaoSelecionada.longitude,
    );

    Navigator.of(context).pop(); 

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
                  markers: _markers,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onTap: (posicao) {
                    _atualizarPosicao(posicao);
                  },
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: panelHeight,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1E3A5F),
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
                  _buildTextField(
                    addressController,
                    "EX: Senai - FSA",
                    onChanged: (valor) {
                      if (!_isUpdatingFromMap) {
                        _buscarLocalizacaoPorEndereco(valor);
                      }
                    },
                  ),
                  _buildSectionTitle("Problema relatado"),
                  _buildTextField(problemController, "EX: Buraco", readOnly: true),
                  _buildSectionTitle("Descrição (opcional)"),
                  _buildTextField(descriptionController, "Descreva o problema..."),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.camera_alt, color: Colors.black, size: 30),
                          if (imageName != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Imagem salva: ${imageName!.length > 15 ? '${imageName!.substring(0, 12)}...' : imageName}',
                              style: const TextStyle(
                                color: Colors.black,
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
                              child: const Icon(
                                Icons.close,
                                color: Colors.red,
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

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
        onChanged: onChanged,
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