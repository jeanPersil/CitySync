import 'package:citysync/widgets/modal_pagina_inicial.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:citysync/views/perfil.dart';
import 'package:citysync/services/reports.dart';
import 'package:citysync/model/model_report.dart';
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

  // ignore: unused_field
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Report> _reports = [];
  bool _isLoading = true;
  bool _disposed = false;

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
    _carregarFotoUsuario();
  }

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
      debugPrint("Erro ao carregar foto do usuário: $e");
    }
  }

  Future<void> _carregarReports() async {
    if (_disposed) return;

    try {
      if (mounted) {
        setState(() => _isLoading = true);
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
      debugPrint("Erro ao carregar reports: $e");
      if (mounted && !_disposed) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _adicionarMarcadores() {
    Set<Marker> novosMarcadores = {};

    for (var report in _reports) {
      BitmapDescriptor markerIcon = _getMarkerIconByStatus(report.nomeStatus);

      novosMarcadores.add(
        Marker(
          markerId: MarkerId('report_${report.id}'),
          position: report.toLatLng(),
          icon: markerIcon,
          // O SEGREDO ESTÁ AQUI: O InfoWindow com onTap configurado
          infoWindow: InfoWindow(
            title: report.nomeCategoria,
            snippet: "Status: ${report.nomeStatus} (Toque para ver)",
            onTap: () {
              // Quando clica no balão branco, abre o modal cinza
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

  BitmapDescriptor _getMarkerIconByStatus(String status) {
    double hue;
    switch (status.toLowerCase().trim()) {
      case 'pendente': hue = BitmapDescriptor.hueOrange; break;
      case 'em andamento': hue = BitmapDescriptor.hueAzure; break;
      case 'resolvido': 
      case 'concluido':
      case 'concluído': hue = BitmapDescriptor.hueGreen; break;
      case 'invalido':
      case 'inválido':
      case 'cancelado': hue = BitmapDescriptor.hueViolet; break;
      default: hue = BitmapDescriptor.hueOrange;
    }
    return BitmapDescriptor.defaultMarkerWithHue(hue);
  }

  Color _getColorByStatus(String status) {
    switch (status.toLowerCase().trim()) {
      case 'pendente': return Colors.orange.shade900;
      case 'em andamento': return Colors.blue.shade800;
      case 'resolvido':
      case 'concluido':
      case 'concluído': return Colors.green.shade800;
      case 'invalido':
      case 'inválido':
      case 'cancelado': return Colors.grey.shade700;
      default: return Colors.black;
    }
  }
  
  Color _getBackgroundColorByStatus(String status) {
     switch (status.toLowerCase().trim()) {
      case 'pendente': return Colors.orange.withValues(alpha: 0.2);
      case 'em andamento': return Colors.blue.withValues( alpha:0.2);
      case 'resolvido':
      case 'concluido':
      case 'concluído': return Colors.green.withValues( alpha:0.2);
      default: return Colors.grey.withValues( alpha:0.2);
    }
  }

  void _mostrarDetalhesReport(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[300], // Estilo Cinza da Imagem 2
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          report.nomeCategoria, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.7,
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
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox(),
                      ),
                    ),
                  ),
                
                _buildLabelValue('Endereço: ', report.endereco),
                const SizedBox(height: 10),

                Row(
                  children: [
                    const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getBackgroundColorByStatus(report.nomeStatus),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getColorByStatus(report.nomeStatus)),
                      ),
                      child: Text(
                        report.nomeStatus,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getColorByStatus(report.nomeStatus),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                if (report.descricao.isNotEmpty) 
                  _buildLabelValue('Descrição: ', report.descricao),
                
                const SizedBox(height: 10),
                _buildLabelValue('Data: ', report.dataSimples),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(backgroundColor: Colors.grey[500]),
            child: const Text('Fechar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelValue(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 16),
        children: [
          TextSpan(text: label, style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    );
  }

  Future<void> _abrirModalReport() async {

    await mostrarModal(context, widget.usuarioID);

    if (mounted && !_disposed) {
      // Atualiza os reports após voltar do modal
      _carregarReports();
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
            title: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileScreen()),
                    );
                    _carregarFotoUsuario();
                  },
                  child: CircleAvatar(
                    backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl!) : null,
                    backgroundColor: Colors.grey[300],
                    child: fotoUrl == null
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Olá, ${widget.nomeUsuario}",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            actions: [
               // Botão de Atualizar Reports na AppBar
               IconButton(
                 icon: const Icon(Icons.refresh, color: Colors.white),
                 tooltip: "Atualizar Reports",
                 onPressed: _carregarReports,
               )
            ],
          ),
        ),
      ),
      
      // Corpo com Mapa (Stack para colocar botão em cima se precisar)
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _senaiFeiraDeSantana,
              zoom: 14,
            ),
            markers: _markers,
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false, // Remove botões de zoom padrão para limpar a tela
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black.withValues( alpha:0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),

      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: _abrirModalReport,
          backgroundColor: const Color(0xFF1E3A5F),
          icon: const Icon(Icons.add_location_alt, color: Colors.white),
          label: const Text("Novo Report", style: TextStyle(color: Colors.white)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}