import 'package:citysync/widgets/modal_pagina_inicial.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:citysync/views/perfil.dart';
import 'package:citysync/services/reports.dart';
import 'package:citysync/model/modelReport.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Telaprincipal extends StatefulWidget {
  const Telaprincipal({
    super.key,
    required this.nomeUsuario,
    required this.usuarioID,
  });

  final String nomeUsuario;
  final String usuarioID;

  @override
  State<Telaprincipal> createState() => _TelaprincipalState();
}

class _TelaprincipalState extends State<Telaprincipal>
    with SingleTickerProviderStateMixin {
  final LatLng _senaiFeiraDeSantana = const LatLng(-12.2663, -38.9458);
  late AnimationController _animationController;
  late Animation<double> _fabAnimation;
  late Animation<double> _appBarFadeAnimation;
  
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Report> _reports = [];
  bool _isLoading = true;
  bool _disposed = false;
  bool _mapaHabilitado = true;

  // Variável para armazenar a URL da foto do usuário
  String? fotoUrl;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _appBarFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
    _carregarReports();
    _carregarFotoUsuario(); // Carrega a foto do usuário ao iniciar
  }

  // Método para carregar a foto do usuário do banco de dados
  Future<void> _carregarFotoUsuario() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final data = await supabase
          .from("users")
          .select("foto_url")
          .eq("id", user.id)
          .maybeSingle();

      if (mounted && data != null) {
        final urlBase = data["foto_url"] as String?;
        if (urlBase != null && urlBase.isNotEmpty) {
          // Adiciona timestamp para evitar cache
          final updatedUrl =
              "$urlBase?t=${DateTime.now().millisecondsSinceEpoch}";

          setState(() {
            fotoUrl = updatedUrl;
          });
        } else {
          setState(() => fotoUrl = null);
        }
      }
    } catch (e) {
      print("Erro ao carregar foto do usuário: $e");
    }
  }

  Future<void> _carregarReports() async {
    if (_disposed) return; 
    
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      
      final reports = await ReportApiService().obterTodosReports();
      
      if (mounted && !_disposed) {
        setState(() {
          _reports = reports;
          _adicionarMarcadores();
          _isLoading = false;
        });
      }
      
    } catch (e) {
      print("Erro ao carregar reports: $e");
      if (mounted && !_disposed) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _adicionarMarcadores() {
    Set<Marker> novosMarcadores = {};

    for (var report in _reports) {
      BitmapDescriptor markerIcon = _getMarkerIconByCategory(report.nomeCategoria);

      novosMarcadores.add(
        Marker(
          markerId: MarkerId('report_${report.id}'),
          position: report.toLatLng(),
          icon: markerIcon,
          infoWindow: InfoWindow(
            title: report.nomeCategoria,
            snippet: report.endereco,
            onTap: () {
              _mostrarDetalhesReport(report);
            },
          ),
        ),
      );
    }

    if (mounted && !_disposed) {
      setState(() {
        _markers = novosMarcadores;
      });
    }
  }

  BitmapDescriptor _getMarkerIconByCategory(String categoria) {
    Color color;
    
    switch (categoria.toLowerCase()) {
      case 'buraco':
        color = Colors.orange;
        break;
      case 'iluminação':
        color = Colors.yellow;
        break;
      case 'lixo':
        color = Colors.green;
        break;
      case 'semafaro':
        color = Colors.red;
        break;
      case 'vazamento/esgoto':
        color = Colors.blue;
        break;
      case 'transporte':
        color = Colors.purple;
        break;
      case 'outros':
        color = Colors.grey;
        break;
      default:
        color = Colors.black;
    }
    
    return BitmapDescriptor.defaultMarkerWithHue(_colorToHue(color));
  }

  double _colorToHue(Color color) {
    if (color == Colors.orange) return BitmapDescriptor.hueOrange;
    if (color == Colors.yellow) return BitmapDescriptor.hueYellow;
    if (color == Colors.green) return BitmapDescriptor.hueGreen;
    if (color == Colors.red) return BitmapDescriptor.hueRed;
    if (color == Colors.blue) return BitmapDescriptor.hueBlue;
    if (color == Colors.purple) return BitmapDescriptor.hueViolet;
    if (color == Colors.grey) return BitmapDescriptor.hueRose;
    return BitmapDescriptor.hueAzure;
  }

  void _mostrarDetalhesReport(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report.nomeCategoria),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (report.urlImagem.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        report.urlImagem,
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: 200,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: 200,
                            color: Colors.grey[300],
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  'Erro ao carregar imagem',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                Text('Endereço: ${report.endereco}'),
                const SizedBox(height: 8),
                Text('Status: ${report.nomeStatus}'),
                if (report.descricao.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Descrição: ${report.descricao}'),
                ],
                const SizedBox(height: 8),
                Text('Data: ${report.dataSimples}'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _abrirModalReport() async {
    setState(() {
      _mapaHabilitado = false;
    });

    await mostrarModal(context, widget.usuarioID);

    if (mounted && !_disposed) {
      setState(() {
        _mapaHabilitado = true;
      });
      
      Future.delayed(const Duration(seconds: 2), () {
        if (!_disposed) {
          _carregarReports();
        }
      });
    }
  }

  @override
  void dispose() {
    _disposed = true; 
    _animationController.dispose();
    _mapController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: FadeTransition(
          opacity: _appBarFadeAnimation,
          child: AppBar(
            backgroundColor: const Color(0xFF1E3A5F),
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.4),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            title: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () async {
                    // Navega para a tela de perfil
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(),
                      ),
                    );

                    // Recarrega a foto ao voltar do perfil
                    _carregarFotoUsuario();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF20C997).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: (fotoUrl != null && fotoUrl!.isNotEmpty)
                          ? Image.network(
                              "$fotoUrl?t=${DateTime.now().millisecondsSinceEpoch}", 
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                // Se houver erro ao carregar, mostra o ícone padrão
                                return const Icon(
                                  Icons.person_outline,
                                  color: Colors.white,
                                  size: 22
                                );
                              },
                            )
                          : const Icon(
                              Icons.person_outline,
                              color: Colors.white,
                              size: 22
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.nomeUsuario,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 18,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black,
                        offset: Offset(0, 1),
                      )
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _carregarReports,
                tooltip: 'Atualizar reports',
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: AbsorbPointer(
                absorbing: !_mapaHabilitado,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _senaiFeiraDeSantana,
                    zoom: 18,
                  ),
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  buildingsEnabled: true,
                  compassEnabled: true,
                  indoorViewEnabled: true,
                  mapToolbarEnabled: true,
                  rotateGesturesEnabled: _mapaHabilitado,
                  scrollGesturesEnabled: _mapaHabilitado,
                  tiltGesturesEnabled: _mapaHabilitado,
                  zoomGesturesEnabled: _mapaHabilitado,
                  markers: _markers,
                  onMapCreated: (controller) {
                    if (!_disposed) {
                      _mapController = controller;
                    }
                  },
                ),
              ),
            ),
          ),
          
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A5F)),
              ),
            ),

          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${_reports.length} reports',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A5F),
                ),
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: 100,
            child: AbsorbPointer(
              absorbing: !_mapaHabilitado,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    onPressed: () {
                      if (!_disposed && _mapaHabilitado) {
                        _mapController?.animateCamera(
                          CameraUpdate.zoomIn(),
                        );
                      }
                    },
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.add, color: Color(0xFF1E3A5F)),
                    heroTag: "zoom_in",
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.small(
                    onPressed: () {
                      if (!_disposed && _mapaHabilitado) {
                        _mapController?.animateCamera(
                          CameraUpdate.zoomOut(),
                        );
                      }
                    },
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.remove, color: Color(0xFF1E3A5F)),
                    heroTag: "zoom_out",
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.small(
                    onPressed: () {
                      if (!_disposed && _mapaHabilitado) {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLng(_senaiFeiraDeSantana),
                        );
                      }
                    },
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: Color(0xFF1E3A5F)),
                    heroTag: "location",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: _abrirModalReport,
            backgroundColor: Colors.redAccent,
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
            label: const Text(
              'Reportar um problema',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}