import 'package:citysync/widgets/modal_pagina_inicial.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:citysync/views/perfil.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  static const Duration _locationTimeout = Duration(seconds: 15);

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
  bool _isMapInteractable = true;
  String _locationError = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeLocation();
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

  // Inicialização da localização com tratamento específico para Web
  Future<void> _initializeLocation() async {
    await _getCurrentLocationWithFallback();
  }

  // Sistema robusto de obtenção de localização com fallbacks
  Future<void> _getCurrentLocationWithFallback() async {
    if (_isLoadingLocation) return;
    
    setState(() {
      _isLoadingLocation = true;
      _locationError = '';
    });

    try {
      // Verificar se estamos na web e usar abordagem específica
      if (kIsWeb) {
        await _getWebLocationWithFallback();
      } else {
        await _getMobileLocationWithFallback();
      }
    } catch (e) {
      _setDefaultLocationWithMessage('Erro crítico: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  // Abordagem específica para Web
  Future<void> _getWebLocationWithFallback() async {
    try {
      // Tentativa 1: Geolocator com configurações específicas para Web
      await _getWebCurrentPosition();
    } catch (e) {
      // Tentativa 2: Usar HTML5 Geolocation API diretamente (fallback)
      await _getHTML5Geolocation();
    }
  }

  // Abordagem para Mobile
  Future<void> _getMobileLocationWithFallback() async {
    try {
      await _getCurrentPositionWithTimeout();
    } catch (e) {
      await _getLastKnownPosition();
    }
  }

  // Geolocator para Web com configurações otimizadas
  Future<void> _getWebCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
          timeLimit: _locationTimeout,
        ),
      );

      await _handleSuccessfulLocation(position);
    } catch (e) {
      _handleWebLocationError(e);
      rethrow;
    }
  }

  // Fallback usando HTML5 Geolocation API diretamente
  Future<void> _getHTML5Geolocation() async {
    try {
      // Esta é uma implementação simulada - na prática precisaríamos de um pacote
      // ou implementação específica para acessar a API diretamente
      _showWebLocationInstructions();
      _setDefaultLocationWithMessage('Localização web requer permissão do navegador');
    } catch (e) {
      _setDefaultLocationWithMessage('Geolocalização não suportada no navegador');
    }
  }

  void _showWebLocationInstructions() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permissão de Localização Necessária'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Para usar a localização no navegador:'),
              SizedBox(height: 10),
              Text('1. Clique no ícone de cadeado na barra de endereços'),
              Text('2. Permita "Localização"'),
              Text('3. Recarregue a página'),
              SizedBox(height: 10),
              Text('Ou use o botão "Minha Localização" no mapa.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Tratamento específico de erros para Web
  void _handleWebLocationError(dynamic error) {
    String errorMessage = 'Erro de localização no navegador';
    
    if (error is TimeoutException || error.toString().contains('Timeout')) {
      errorMessage = 'Tempo limite excedido. Verifique sua conexão.';
    } else if (error.toString().contains('PERMISSION_DENIED')) {
      errorMessage = 'Permissão de localização negada no navegador';
      _showWebLocationInstructions();
    } else if (error.toString().contains('POSITION_UNAVAILABLE')) {
      errorMessage = 'Localização indisponível no navegador';
    } else if (error.toString().contains('TIMEOUT')) {
      errorMessage = 'Tempo esgotado para obter localização';
    }
    
    _handleLocationError(errorMessage);
  }

  // Obter posição atual com timeout (Mobile)
  Future<void> _getCurrentPositionWithTimeout() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
          timeLimit: _locationTimeout,
        ),
      ).timeout(_locationTimeout);

      if (mounted) {
        await _handleSuccessfulLocation(position);
      }
    } catch (e) {
      _handleLocationError('Erro mobile: ${e.toString()}');
      rethrow;
    }
  }

  // Tentar obter última localização conhecida
  Future<void> _getLastKnownPosition() async {
    try {
      final Position? position = await Geolocator.getLastKnownPosition();
      
      if (position != null && mounted) {
        await _handleSuccessfulLocation(position);
      } else {
        _setDefaultLocationWithMessage('Usando localização padrão');
      }
    } catch (e) {
      _setDefaultLocationWithMessage('Erro última localização: ${e.toString()}');
    }
  }

  // Processar localização obtida com sucesso
  Future<void> _handleSuccessfulLocation(Position position) async {
    final newLocation = LatLng(position.latitude, position.longitude);
    
    setState(() {
      _currentLocation = newLocation;
      _selectedLocation = newLocation;
    });
    
    _updateMarker(newLocation);
    _moveToLocation(newLocation);
    await _getAddressFromLatLng(newLocation);
    
    if (mounted) {
      setState(() {
        _locationError = '';
      });
    }
  }

  // Tratar erro de localização
  void _handleLocationError(String error) {
    if (mounted) {
      setState(() {
        _locationError = error;
      });
      
      // Mostrar snackbar apenas para erros não relacionados a permissão
      if (!error.contains('negada')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Tentar',
              onPressed: _getCurrentLocationWithFallback,
            ),
          ),
        );
      }
    }
    _setDefaultLocationWithMessage(error);
  }

  void _setDefaultLocationWithMessage(String message) {
    if (mounted) {
      setState(() {
        _currentLocation = _senaiFeiraDeSantana;
        _selectedLocation = _senaiFeiraDeSantana;
        _locationError = message;
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
    if (!_isMapInteractable) return;
    
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
        String street = place.street ?? 'Rua não identificada';
        String locality = place.locality ?? 'Cidade não identificada';
        String administrativeArea = place.administrativeArea ?? 'Estado não identificado';
        
        setState(() {
          _selectedAddress = '$street, $locality, $administrativeArea';
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
      CameraUpdate.newLatLngZoom(location, _initialZoom),
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
      _isMapInteractable = false;
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
          _isMapInteractable = true;
        });
      }
    });
  }

  // Funções dos botões do mapa
  void _zoomIn() {
    if (!_isMapInteractable) return;
    
    _mapController?.getZoomLevel().then((currentZoom) {
      _mapController?.animateCamera(
        CameraUpdate.zoomTo(currentZoom + 1),
      );
    });
  }

  void _zoomOut() {
    if (!_isMapInteractable) return;
    
    _mapController?.getZoomLevel().then((currentZoom) {
      _mapController?.animateCamera(
        CameraUpdate.zoomTo(currentZoom - 1),
      );
    });
  }

  void _goToMyLocation() {
    if (!_isMapInteractable) return;
    _getCurrentLocationWithFallback();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng position) {
    if (!_isMapInteractable) return;
    
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
          actions: [
            if (_locationError.isNotEmpty)
              IconButton(
                icon: Icon(
                  kIsWeb ? Icons.location_disabled : Icons.warning_amber,
                  color: Colors.orange,
                ),
                onPressed: () {
                  if (kIsWeb) {
                    _showWebLocationInstructions();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_locationError),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                },
              ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _isLoadingLocation ? null : _getCurrentLocationWithFallback,
            ),
          ],
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
              if (_locationError.isNotEmpty && kIsWeb)
                Text(
                  'Clique no ícone ⚠️ para instruções',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                  ),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Obtendo localização...',
                  style: TextStyle(color: Colors.white),
                ),
                if (kIsWeb) ...[
                  SizedBox(height: 8),
                  Text(
                    'Verifique as permissões do navegador',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        if (!_isMapInteractable)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {},
              onPanStart: (_) {},
              child: Container(
                color: Colors.transparent,
              ),
            ),
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
          rotateGesturesEnabled: _isMapInteractable && !_isModalOpen,
          scrollGesturesEnabled: _isMapInteractable && !_isModalOpen,
          tiltGesturesEnabled: _isMapInteractable && !_isModalOpen,
          zoomGesturesEnabled: _isMapInteractable && !_isModalOpen,
          markers: _locationMarker != null ? {_locationMarker!} : <Marker>{},
          onMapCreated: _onMapCreated,
          onTap: _isMapInteractable ? _onMapTap : null,
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
      onPressed: _isMapInteractable ? onPressed : null,
      backgroundColor: _isMapInteractable ? Colors.white : Colors.grey,
      heroTag: heroTag,
      child: Icon(
        icon, 
        color: _isMapInteractable ? const Color(0xFF1E3A5F) : Colors.grey[600],
      ),
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
          onPressed: _isMapInteractable ? _showProblemModal : null,
          backgroundColor: _isMapInteractable ? Colors.redAccent : Colors.grey,
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