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
  // Controladores de Texto
  final TextEditingController addressController = TextEditingController();
  final TextEditingController problemController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Estado do Mapa
  final LatLng _initialPosicao = const LatLng(-12.2664, -38.9668);
  LatLng _posicaoSelecionada = const LatLng(-12.2664, -38.9668);
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  
  // Controle para evitar loop infinito entre mapa e texto
  bool _isUpdatingFromMap = false;

  // 🔒 NOVA VARIÁVEL: Controla se o mapa aceita toques ou não
  bool _mapaInterativo = true;

  // Imagem
  Uint8List? imageBytes;
  io.File? imageFile;
  String? imageName;

  // Google API Key 
  static const String _googleApiKey = "AIzaSyBuuPoXMIcbCOMSgIzTnHENU9jzfzb22nc";

  // Limites de Feira de Santana
  static final LatLngBounds _fsaBounds = LatLngBounds(
    southwest: const LatLng(-12.35, -39.05),
    northeast: const LatLng(-12.15, -38.85),
  );

  static const MinMaxZoomPreference _zoomPreference = MinMaxZoomPreference(
    13.0,
    20.0,
  );

  @override
  void initState() {
    super.initState();
    problemController.text = widget.categoria;
    _posicaoSelecionada = _initialPosicao;
    _adicionarMarcador(_initialPosicao, snippet: "Segure e arraste para ajustar");
  }

  @override
  void dispose() {
    addressController.dispose();
    problemController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // --- LÓGICA DO MAPA E MARCADORES ---

  void _adicionarMarcador(LatLng posicao, {String? titulo, String? snippet}) {
    if (!mounted) return;

    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('local_selecionado'),
          position: posicao,
          draggable: true, // O bloqueio real acontece no build usando copyWith
          infoWindow: InfoWindow(
            title: titulo ?? "Local Selecionado",
            snippet: snippet ?? "Segure e arraste para ajustar",
          ),
          onDragEnd: (novaPosicao) {
            // Segurança extra: só atualiza se estiver interativo
            if (_mapaInterativo) {
              _atualizarPosicao(novaPosicao);
            }
          },
        ),
      );
    });
  }

  void _atualizarPosicao(LatLng novaPosicao) async {
    // Se o mapa estiver bloqueado, ignora
    if (!_mapaInterativo) return;

    setState(() {
      _posicaoSelecionada = novaPosicao;
      _isUpdatingFromMap = true; 
    });

    _adicionarMarcador(novaPosicao, snippet: "Buscando endereço...");
    
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(novaPosicao),
    );

    try {
      if (_googleApiKey.isEmpty) {
        addressController.text = "Lat: ${novaPosicao.latitude}, Lng: ${novaPosicao.longitude}";
        return;
      }

      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${novaPosicao.latitude},${novaPosicao.longitude}&key=$_googleApiKey&language=pt-BR');

      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          String endereco = data['results'][0]['formatted_address'];
          endereco = endereco.replaceAll(', Brasil', '');

          addressController.text = endereco;

          _adicionarMarcador(
            novaPosicao, 
            titulo: "Endereço Encontrado", 
            snippet: endereco 
          );
          
        } else {
          addressController.text = "Endereço desconhecido";
        }
      }
    } catch (e) {
      debugPrint("❌ Erro ao buscar endereço: $e");
    } finally {
      if (mounted) {
        setState(() {
           _isUpdatingFromMap = false;
        });
      }
    }
  }

  void _buscarLocalizacaoPorEndereco(String endereco) async {
    if (endereco.isEmpty || _isUpdatingFromMap || endereco.length < 3) return;

    try {
      String enderecoCompleto = endereco;
      if (!endereco.toLowerCase().contains('feira de santana')) {
        enderecoCompleto = "$endereco, Feira de Santana, BA, Brasil";
      }

      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(enderecoCompleto)}&key=$_googleApiKey&language=pt-BR');

      final response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          final LatLng novaPosicao = LatLng(location['lat'], location['lng']);
          final String enderecoFormatado = data['results'][0]['formatted_address'];

          setState(() {
            _posicaoSelecionada = novaPosicao;
          });

          _adicionarMarcador(novaPosicao, snippet: enderecoFormatado);
          
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(novaPosicao, 16),
          );
        }
      }
    } catch (e) {
      debugPrint("Erro ao buscar localização: $e");
    }
  }

  // --- LÓGICA DE IMAGEM ---

  Future<void> pickImage() async {
    final picker = ImagePicker();

    try {
      if (kIsWeb) {
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          if (!mounted) return;
          setState(() {
            imageBytes = bytes;
            imageName = pickedFile.name;
            imageFile = null;
          });
        }
      } else {
        final pickedFile = await picker.pickImage(source: ImageSource.camera);
        if (pickedFile != null) {
          if (!mounted) return;
          setState(() {
            imageFile = io.File(pickedFile.path);
            imageName = pickedFile.name;
            imageBytes = null;
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao selecionar imagem: $e");
    }
  }

  // 🔒 AQUI ESTÁ A LÓGICA DE BLOQUEIO DO MAPA
  void _abrirVisualizacaoImagem() async { // Adicionado async
    if (imageBytes == null) return;

    // 1. Bloqueia o mapa
    setState(() {
      _mapaInterativo = false;
    });

    // 2. Abre o modal e espera ele fechar (await)
    await showDialog(
      context: context,
      barrierDismissible: false, 
      barrierColor: Colors.black.withValues(alpha: 0.9), 
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  panEnabled: true, 
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.memory(
                    imageBytes!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 50,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // 3. Desbloqueia o mapa quando o modal fechar
    if (mounted) {
      setState(() {
        _mapaInterativo = true;
      });
    }
  }

  // --- LÓGICA DE ENVIO ---

  int mapearCategoriaId(String nome) {
    switch (nome.toLowerCase()) {
      case 'buraco': return 1;
      case 'iluminação': return 2;
      case 'lixo': return 3;
      case 'semafaro': return 4;
      case 'vazamento/esgoto': return 5;
      case 'transporte': return 6;
      case 'outros': return 7;
      default: return 5; 
    }
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

        if (!mounted) return;
        if (urlImagem == null) {
          Navigator.of(context).pop(); 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erro ao fazer upload da imagem.")),
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

      if (!mounted) return;
      Navigator.of(context).pop(); 

      if (resultado == null) {
        Navigator.of(context).pop(); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Problema reportado com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $resultado"), backgroundColor: Colors.red),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verifique o endereço.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final panelHeight = screenHeight * 0.65; 

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosicao,
                zoom: 16,
              ),
              
              // 🔒 USO DA VARIÁVEL DE BLOQUEIO NO MAPA
              scrollGesturesEnabled: _mapaInterativo,
              zoomGesturesEnabled: _mapaInterativo,
              tiltGesturesEnabled: _mapaInterativo,
              rotateGesturesEnabled: _mapaInterativo,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: _mapaInterativo,
              
              // Se não estiver interativo, o clique é nulo
              onTap: _mapaInterativo ? _atualizarPosicao : null,

              // 🔒 FORÇA O MARCADOR A NÃO SER DRAGGABLE SE O MAPA ESTIVER TRAVADO
              markers: _markers.map((m) {
                return m.copyWith(draggableParam: _mapaInterativo);
              }).toSet(),

              onMapCreated: (controller) => _mapController = controller,
              cameraTargetBounds: CameraTargetBounds(_fsaBounds),
              minMaxZoomPreference: _zoomPreference,
              myLocationEnabled: true,
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
                    "Buscando endereço...",
                    onChanged: (valor) {
                      if (!_isUpdatingFromMap) _buscarLocalizacaoPorEndereco(valor);
                    },
                  ),
                  
                  _buildSectionTitle("Problema relatado"),
                  _buildTextField(
                    problemController, 
                    "Categoria",
                    readOnly: true
                  ),
                  
                  _buildSectionTitle("Descrição (opcional)"),
                  _buildTextField(
                    descriptionController, 
                    "Descreva o problema com detalhes..."
                  ),
                  
                  const SizedBox(height: 15),
                  
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.camera_alt, color: Colors.black, size: 28),
                          if (imageName != null) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Imagem: ${imageName!.length > 15 ? '${imageName!.substring(0, 12)}...' : imageName}',
                                style: const TextStyle(color: Colors.black, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() {
                                imageBytes = null;
                                imageFile = null;
                                imageName = null;
                              }),
                              child: const Icon(Icons.close, color: Colors.red, size: 20),
                            ),
                          ] else ...[
                            const SizedBox(width: 8),
                            const Text("Adicionar Foto", style: TextStyle(color: Colors.black)),
                          ]
                        ],
                      ),
                    ),
                  ),

                  if (imageName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextButton.icon(
                        onPressed: _abrirVisualizacaoImagem,
                        icon: const Icon(Icons.visibility, color: Colors.white),
                        label: const Text("Visualizar Foto", style: TextStyle(color: Colors.white)),
                      ),
                    ),

                  const SizedBox(height: 25),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _reportarProblema,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text("REPORTAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text("CANCELAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), 
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
          filled: true,
          fillColor: Colors.white.withValues( alpha:0.1),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white54),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}