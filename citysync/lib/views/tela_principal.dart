import 'package:citysync/widgets/modal_pagina_inicial.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:citysync/views/perfil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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

  // Controladores
  late AnimationController _animationController;
  late Animation<double> _fabAnimation;
  late Animation<double> _appBarFadeAnimation;
  GoogleMapController? _mapController;
  bool _isModalOpen = false;

  // Localização e marcador
  LatLng? _currentLocation;
  LatLng? _selectedLocation;
  Marker? _locationMarker;
  String? _selectedAddress;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _getCurrentLocation();
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

  // Obter localização atual do usuário
  Future<void> _getCurrentLocation() async {
    if (_isLoadingLocation) return;
    
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Verificar permissões
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setDefaultLocation();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setDefaultLocation();
        return;
      }

      // Obter posição atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _selectedLocation = _currentLocation;
        });
        _updateMarker(_currentLocation!);
        _moveToLocation(_currentLocation!);
        _getAddressFromLatLng(_currentLocation!);
      }
    } catch (e) {
      _setDefaultLocation();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _setDefaultLocation() {
    if (mounted) {
      setState(() {
        _currentLocation = _senaiFeiraDeSantana;
        _selectedLocation = _senaiFeiraDeSantana;
      });
      _updateMarker(_senaiFeiraDeSantana);
      _moveToLocation(_senaiFeiraDeSantana);
    }
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _locationMarker = Marker(
        markerId: const MarkerId('selected_location'),
        position: position,
        draggable: true,
        onDragEnd: (newPosition) {
          _onMarkerDragEnd(newPosition);
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(
          title: 'Local do Problema',
          snippet: 'Arraste para ajustar a localização',
        ),
      );
    });
  }

  void _onMarkerDragEnd(LatLng newPosition) {
    setState(() {
      _selectedLocation = newPosition;
    });
    _getAddressFromLatLng(newPosition);
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _selectedAddress = '${place.street}, ${place.locality}, ${place.administrativeArea}';
        });
      } else {
        setState(() {
          _selectedAddress = 'Endereço não encontrado';
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = 'Erro ao obter endereço';
      });
    }
  }

  void _moveToLocation(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(location),
    );
  }

  void _navigateToProfile() {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileScreen()),
    );
  }

  void _showProblemModal() {
    if (!mounted || _selectedLocation == null) return;
    
    setState(() {
      _isModalOpen = true;
    });
    
    mostrarModal(
      context, 
      widget.usuarioID,
      selectedLocation: _selectedLocation!,
      selectedAddress: _selectedAddress ?? 'Endereço não disponível',
    ).then((_) {
      if (mounted) {
        setState(() {
          _isModalOpen = false;
        });
      }
    });
  }

  // Funções dos botões do mapa
  void _zoomIn() {
    _mapController?.getZoomLevel().then((currentZoom) {
      _mapController?.animateCamera(
        CameraUpdate.zoomTo(currentZoom + 1),
      );
    });
  }

  void _zoomOut() {
    _mapController?.getZoomLevel().then((currentZoom) {
      _mapController?.animateCamera(
        CameraUpdate.zoomTo(currentZoom - 1),
      );
    });
  }

  void _goToMyLocation() {
    if (_currentLocation != null) {
      _moveToLocation(_currentLocation!);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });
    _updateMarker(position);
    _getAddressFromLatLng(position);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mapController?.dispose();
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              if (_selectedAddress != null)
                Text(
                  _selectedAddress!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
        if (_isLoadingLocation)
          const Center(
            child: CircularProgressIndicator(),
          ),
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
            target: _currentLocation ?? _senaiFeiraDeSantana,
            zoom: _initialZoom,
          ),
          mapType: MapType.normal,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          buildingsEnabled: true,
          compassEnabled: true,
          indoorViewEnabled: true,
          mapToolbarEnabled: true,
          // Bloqueia interações quando modal está aberto
          rotateGesturesEnabled: !_isModalOpen,
          scrollGesturesEnabled: !_isModalOpen,
          tiltGesturesEnabled: !_isModalOpen,
          zoomGesturesEnabled: !_isModalOpen,
          markers: _locationMarker != null 
              ? Set<Marker>.of([_locationMarker!]) 
              : Set<Marker>(),
          onMapCreated: _onMapCreated,
          onTap: _onMapTap,
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
            onPressed: _zoomIn,
          ),
          const SizedBox(height: 10),
          _buildMapControlButton(
            icon: Icons.remove,
            heroTag: "zoom_out",
            onPressed: _zoomOut,
          ),
          const SizedBox(height: 10),
          _buildMapControlButton(
            icon: Icons.my_location,
            heroTag: "location",
            onPressed: _goToMyLocation,
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