import 'package:citysync/widgets/modal_pagina_inicial.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:citysync/views/perfil.dart';
import 'package:citysync/services/reports.dart';
import 'package:citysync/model/modelReport.dart';

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
  bool _disposed = false; // NOVA FLAG PARA CONTROLAR DISPOSE

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
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Endereço: ${report.endereco}'),
              Text('Status: ${report.nomeStatus}'),
              if (report.descricao.isNotEmpty)
                Text('Descrição: ${report.descricao}'),
              Text('Data: ${report.dataCriacao}'),
            ],
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
            shadowColor: Colors.black.withOpacity(0.4),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            title: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF20C997).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 22,
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
                  color: Colors.black.withOpacity(0.4),
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
                rotateGesturesEnabled: true,
                scrollGesturesEnabled: true,
                tiltGesturesEnabled: true,
                zoomGesturesEnabled: true,
                markers: _markers,
                onMapCreated: (controller) {
                  if (!_disposed) {
                    _mapController = controller;
                  }
                },
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
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
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
            child: Column(
              children: [
                FloatingActionButton.small(
                  onPressed: () {
                    if (!_disposed) {
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
                    if (!_disposed) {
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
                    if (!_disposed) {
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
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () {
              mostrarModal(context, widget.usuarioID);
              Future.delayed(const Duration(seconds: 2), () {
                if (!_disposed) {
                  _carregarReports();
                }
              });
            },
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