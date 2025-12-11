import 'dart:typed_data';
import 'dart:io' as io show File;
import 'dart:convert';
import 'dart:async';

import 'package:citysync/services/reports.dart'; // Mantenha seu import de serviço
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';

class TelaReport extends StatefulWidget {
  const TelaReport({
    super.key, 
    required this.usuarioId, 
    required this.categoria
  });

  final String usuarioId;
  final String categoria;

  @override
  TelaReportState createState() => TelaReportState();
}

class TelaReportState extends State<TelaReport> {
  // --- CONTROLLERS ---
  final TextEditingController addressController = TextEditingController();
  final TextEditingController problemController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // --- MAPA ---
  GoogleMapController? _mapController;
  final LatLng _initialPosicao = LatLng(-12.2664, -38.9668); // Feira de Santana
  LatLng _posicaoSelecionada = LatLng(-12.2664, -38.9668);
  Set<Marker> _markers = {};
  
  // Limites geográficos (Feira de Santana)
  static final LatLngBounds _fsaBounds = LatLngBounds(
    southwest: const LatLng(-12.35, -39.05),
    northeast: const LatLng(-12.15, -38.85),
  );

  // --- CONTROLE DE ESTADO ---
  bool _isUpdatingFromMap = false;
  
  // --- CONTROLE DE REDIMENSIONAMENTO DO PAINEL ---
  double _panelHeight = 400.0; // Altura inicial do painel
  final double _minPanelHeight = 150.0; // Altura mínima (apenas o topo visível)

  // --- API KEYS ---
  static const String _googleApiKey = "AIzaSyBuuPoXMIcbCOMSgIzTnHENU9jzfzb22nc";
  final String _proxyUrl = "https://cors-anywhere.herokuapp.com/";

  // --- IMAGEM ---
  Uint8List? imageBytes;
  io.File? imageFile;
  String? imageName;

  @override
  void initState() {
    super.initState();
    problemController.text = widget.categoria;
    _posicaoSelecionada = _initialPosicao;
    _adicionarMarcador(_initialPosicao);
    
    // Busca endereço inicial para preencher o campo
    _atualizarPosicao(_initialPosicao);
  }

  // ===========================================================================
  //  LÓGICA DE REDIMENSIONAMENTO (DRAG)
  // ===========================================================================
  
  void _onPanelDrag(DragUpdateDetails details) {
    setState(() {
      // O dy é negativo quando arrasta para cima.
      // Subtraímos o delta: menos com menos dá mais (aumenta altura)
      _panelHeight -= details.delta.dy;

      final screenHeight = MediaQuery.of(context).size.height;
      final maxHeight = screenHeight * 0.85; // Limite máximo de 85% da tela

      // Clamp garante que não fique nem muito pequeno nem maior que a tela
      _panelHeight = _panelHeight.clamp(_minPanelHeight, maxHeight);
    });
  }

  // ===========================================================================
  //  LÓGICA DE MAPA E API
  // ===========================================================================

  void _adicionarMarcador(LatLng posicao) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('local_selecionado'),
          position: posicao,
          draggable: true,
          onDragEnd: (novaPosicao) {
            _atualizarPosicao(novaPosicao);
          },
        ),
      );
    });
  }

  void _atualizarPosicao(LatLng novaPosicao, {bool fromSearch = false}) async {
    setState(() {
      _posicaoSelecionada = novaPosicao;
      if (!fromSearch) _isUpdatingFromMap = true;
    });

    _adicionarMarcador(novaPosicao);
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(novaPosicao, 17.0),
    );

    if (fromSearch) {
       _isUpdatingFromMap = false;
       return; 
    }

    try {
      String baseUrl = "https://maps.googleapis.com/maps/api/geocode/json";
      String url = kIsWeb ? "$_proxyUrl$baseUrl" : baseUrl;
      final requestUrl = Uri.parse('$url?latlng=${novaPosicao.latitude},${novaPosicao.longitude}&key=$_googleApiKey&language=pt-BR');

      final response = await http.get(requestUrl);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          String endereco = data['results'][0]['formatted_address'];
          endereco = endereco.replaceAll(', Brasil', '');
          
          setState(() {
             addressController.text = endereco;
          });
        }
      }
    } catch (e) {
      print("Erro ao buscar endereço reverso: $e");
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
             _isUpdatingFromMap = false;
          });
        }
      });
    }
  }

  Future<List<Map<String, dynamic>>> buscarEnderecos(String query) async {
    if (query.isEmpty) return [];

    String baseUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    String url = kIsWeb ? "$_proxyUrl$baseUrl" : baseUrl;
    String requestUrl = "$url?input=$query&key=$_googleApiKey&language=pt_BR&components=country:br&location=${_posicaoSelecionada.latitude},${_posicaoSelecionada.longitude}&radius=10000";

    try {
      final response = await http.get(Uri.parse(requestUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return List<Map<String, dynamic>>.from(data['predictions'].map((p) => {
                'description': p['description'],
                'place_id': p['place_id']
              }));
        }
      }
    } catch (e) {
      print("Erro no Autocomplete: $e");
    }
    return [];
  }

  Future<void> obterDetalhesDoLocal(String placeId) async {
    String baseUrl = "https://maps.googleapis.com/maps/api/place/details/json";
    String url = kIsWeb ? "$_proxyUrl$baseUrl" : baseUrl;
    String requestUrl = "$url?place_id=$placeId&fields=geometry&key=$_googleApiKey";

    try {
      final response = await http.get(Uri.parse(requestUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          final novaPosicao = LatLng(location['lat'], location['lng']);
          _atualizarPosicao(novaPosicao, fromSearch: true);
        }
      }
    } catch (e) {
      print("Erro details: $e");
    }
  }

  // ===========================================================================
  //  IMAGEM E SUBMISSÃO
  // ===========================================================================

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
                    child: const Icon(Icons.close, size: 28, color: Colors.black),
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
    if (addressController.text.isNotEmpty && problemController.text.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      String? urlImagem;
      if (imageName != null) {
        urlImagem = await ReportApiService().uploadImagem(
          imageFile: imageFile,
          imageBytes: imageBytes,
          imageName: imageName!,
        );
        if (urlImagem == null) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erro ao fazer upload da imagem")),
          );
          return;
        }
      }

      final resultado = await ReportApiService().enviarReport(
        endereco: addressController.text,
        categoriaId: mapearCategoriaId(widget.categoria),
        usuarioId: widget.usuarioId,
        descricao: descriptionController.text,
        urlImagem: urlImagem,
        latitude: _posicaoSelecionada.latitude,
        longitude: _posicaoSelecionada.longitude,
      );

      Navigator.of(context).pop(); // fecha loading

      if (resultado == null) {
        Navigator.of(context).pop(); // fecha tela
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
        const SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios.')),
      );
    }
  }

  // ===========================================================================
  //  INTERFACE (BUILD)
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1E3A5F);

    return Scaffold(
      // Importante: Impede que o teclado empurre o layout e quebre o mapa
      resizeToAvoidBottomInset: false, 
      body: Column(
        children: [
          // 1. ÁREA DO MAPA (EXPANDED)
          // Ocupa todo o espaço vertical que sobrar da Coluna
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialPosicao,
                    zoom: 16,
                  ),
                  markers: _markers,
                  onMapCreated: (controller) => _mapController = controller,
                  onTap: (posicao) => _atualizarPosicao(posicao),
                  cameraTargetBounds: CameraTargetBounds(_fsaBounds),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  // Padding opcional para controles do mapa não ficarem muito na borda
                  padding: const EdgeInsets.only(bottom: 20, left: 10),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: SafeArea(
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. O PAINEL ARRASTÁVEL
          GestureDetector(
            onVerticalDragUpdate: _onPanelDrag, // Detecta o arraste vertical
            child: Container(
              height: _panelHeight, // Altura dinâmica
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))
                ],
              ),
              child: Column(
                children: [
                  // Puxador Visual (Handle)
                  Container(
                    width: double.infinity,
                    color: Colors.transparent, // Área de toque
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    alignment: Alignment.center,
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Conteúdo do Formulário (Rolável)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSectionTitle("Endereço selecionado:"),
                          
                          // --- TYPE AHEAD FIELD (Busca) ---
                          TypeAheadField<Map<String, dynamic>>(
                            controller: addressController,
                            builder: (context, controller, focusNode) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: "Digite para buscar ou clique no mapa",
                                  hintStyle: const TextStyle(color: Colors.white70),
                                  filled: false,
                                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white, width: 2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              );
                            },
                            suggestionsCallback: (pattern) async {
                              if (_isUpdatingFromMap) return [];
                              return await buscarEnderecos(pattern);
                            },
                            itemBuilder: (context, suggestion) {
                              return ListTile(
                                leading: const Icon(Icons.location_on, color: Color(0xFF1E3A5F)),
                                title: Text(suggestion['description']),
                              );
                            },
                            onSelected: (suggestion) {
                              addressController.text = suggestion['description'];
                              obterDetalhesDoLocal(suggestion['place_id']);
                            },
                            emptyBuilder: (context) => const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Nenhum endereço encontrado'),
                            ),
                          ),

                          _buildSectionTitle("Problema relatado"),
                          _buildTextField(problemController, "Categoria", readOnly: true),

                          _buildSectionTitle("Descrição (opcional)"),
                          _buildTextField(descriptionController, "Descreva o problema..."),

                          const SizedBox(height: 15),

                          // --- FOTO ---
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
                                      style: const TextStyle(color: Colors.black, fontSize: 14),
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
                                      child: const Icon(Icons.close, color: Colors.red, size: 20),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          
                          if (imageName != null)
                            TextButton(
                              onPressed: _abrirVisualizacaoImagem,
                              child: const Text("Visualizar Imagem", style: TextStyle(color: Colors.white, decoration: TextDecoration.underline)),
                            ),

                          const SizedBox(height: 20),

                          // --- BOTÕES ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: _reportarProblema,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  child: const Text("Reportar", style: TextStyle(color: Colors.white)),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  child: const Text("Cancelar", style: TextStyle(color: Colors.black)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30), // Espaço extra no fim
                        ],
                      ),
                    ),
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
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool readOnly = false}) {
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