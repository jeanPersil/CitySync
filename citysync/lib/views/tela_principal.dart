import 'package:citysync/widgets/modal_pagina_inicial.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Telaprincipal extends StatefulWidget {
  const Telaprincipal(
      {super.key, required this.nomeUsuario, required this.usuarioID});

  final String nomeUsuario;
  final int usuarioID;

  @override
  State<Telaprincipal> createState() => _TelaprincipalState();
}

class _TelaprincipalState extends State<Telaprincipal>
    with SingleTickerProviderStateMixin {
  final LatLng _senaiFeiraDeSantana = const LatLng(-12.2663, -38.9458);
  late AnimationController _animationController;
  late Animation<double> _fabAnimation;
  late Animation<double> _appBarFadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animação para o FAB e AppBar
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? Colors.grey[900]
          : const Color(0xFF1E3A5F) ,
      appBar: PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
        child: FadeTransition(
      opacity: _appBarFadeAnimation,
        child: AppBar(
      backgroundColor: isDark
          ? Colors.grey[900]
          : const Color(0xFF1E3A5F) ,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF20C997).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline,
                color: Colors.white, size: 22),
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
    ),
  ),
),

      body: Stack(
        children: [
          // Mapa
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
              ),
            ),
          ),
          
          
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                
                FloatingActionButton.small(
                  onPressed: () {},
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Color(0xFF1E3A5F)),
                  heroTag: "zoom_in",
                ),
                 SizedBox(height: 10),
                
                FloatingActionButton.small(
                  onPressed: () {},
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: Color(0xFF1E3A5F)),
                  heroTag: "zoom_out",
                ),
                const SizedBox(height: 10),
                
                FloatingActionButton.small(
                  onPressed: () {},
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
            onPressed: () => mostrarModal(context, widget.usuarioID),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
      
    );
  }
}