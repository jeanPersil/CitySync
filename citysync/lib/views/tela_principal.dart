import 'package:citysync/widgets/modal_pagina_inicial.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:citysync/views/perfil.dart';

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
      
  // Constantes
  static const LatLng _senaiFeiraDeSantana = LatLng(-12.2663, -38.9458);
  static const double _initialZoom = 18.0;
  static const Duration _animationDuration = Duration(milliseconds: 800);

  // Controladores de animação
  late AnimationController _animationController;
  late Animation<double> _fabAnimation;
  late Animation<double> _appBarFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: _animationDuration,
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

  void _navigateToProfile() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen()),
    );
  }

  void _showProblemModal() {
    if (!mounted) return;
    mostrarModal(context, widget.usuarioID);
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
      backgroundColor: isDark ? Colors.grey[900] : const Color(0xFF1E3A5F),
      appBar: _buildAppBar(isDark),
      body: _buildBody(),
      floatingActionButton: _buildMainFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: FadeTransition(
        opacity: _appBarFadeAnimation,
        child: AppBar(
          backgroundColor: isDark ? Colors.grey[900] : const Color(0xFF1E3A5F),
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.4),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
          title: _buildAppBarTitle(),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        // Ícone do usuário clicável
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: _navigateToProfile,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF20C997).withValues(alpha: 0.2),
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
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _buildMap(),
        _buildMapControls(),
      ],
    );
  }

  Widget _buildMap() {
    return Container(
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
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _senaiFeiraDeSantana,
            zoom: _initialZoom,
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
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          _buildMapControlButton(
            icon: Icons.add,
            heroTag: "zoom_in",
            onPressed: () {}, // Implementar zoom in
          ),
          const SizedBox(height: 10),
          _buildMapControlButton(
            icon: Icons.remove,
            heroTag: "zoom_out",
            onPressed: () {}, // Implementar zoom out
          ),
          const SizedBox(height: 10),
          _buildMapControlButton(
            icon: Icons.my_location,
            heroTag: "location",
            onPressed: () {}, // Implementar localização
          ),
        ],
      ),
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required String heroTag,
    required VoidCallback onPressed,
  }) {
    return FloatingActionButton.small(
      onPressed: onPressed,
      backgroundColor: Colors.white,
      heroTag: heroTag,
      child: Icon(icon, color: const Color(0xFF1E3A5F)),
    );
  }

  Widget _buildMainFloatingActionButton() {
    return ScaleTransition(
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
          onPressed: _showProblemModal,
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
    );
  }
}