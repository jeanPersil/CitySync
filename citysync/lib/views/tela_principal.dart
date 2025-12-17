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
  
  // Posição inicial (SENAI Feira de Santana)
  final LatLng _posicaoInicial = const LatLng(-12.2663, -38.9458);
  
  late AnimationController _animationController;
  late Animation<double> _fabAnimation;
  late Animation<double> _appBarFadeAnimation;

  GoogleMapController? _mapController;
  
  // Dados do Mapa
  Set<Marker> _markers = {};
  List<Report> _reports = [];
  
  // Estado
  bool _isLoading = true;
  bool _disposed = false;
  String? fotoUrl;

  int _markerVersion = 0; 

  @override
  void initState() {
    super.initState();

    // Configuração das animações
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _appBarFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    
    // Carregamento inicial
    _carregarReports();
    _carregarFotoUsuario();
  }

  Future<void> _carregarFotoUsuario() async {
    try {
      final supabase = Supabase.instance.client;
      final data = await supabase
          .from("users")
          .select("foto_url")
          .eq("id", widget.usuarioID)
          .maybeSingle();

      if (mounted && !_disposed && data != null) {
        final urlBase = data["foto_url"] as String?;
        if (urlBase != null && urlBase.isNotEmpty) {
          final updatedUrl = "$urlBase?t=${DateTime.now().millisecondsSinceEpoch}";
          setState(() {
            fotoUrl = updatedUrl;
          });
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar foto: $e");
    }
  }

  Future<void> _carregarReports() async {
    if (_disposed) return;
    
    if (_reports.isEmpty && mounted) {
      setState(() => _isLoading = true);
    }
      
    try {
      final reports = await ReportApiService().obterTodosReports();

      _markerVersion++;

      final novosMarcadores = _gerarMarcadores(reports);
      
      if (mounted && !_disposed) {
        setState(() {
          _reports = reports;
          _markers = novosMarcadores;
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

  // --- Lógica de Marcadores (MODIFICADA PARA CORRIGIR O BUG) ---

  Set<Marker> _gerarMarcadores(List<Report> listaReports) {
    return listaReports.map((report) {
      BitmapDescriptor icone = _definirCorDoIcone(report);
      String emojiStatus = _obterEmojiStatus(report.nomeStatus);
      final String markerIdUnico = 'report_${report.id}_v$_markerVersion';

      return Marker(
        markerId: MarkerId(markerIdUnico),
        position: report.toLatLng(),
        icon: icone,
        
        consumeTapEvents: true, 
        
        infoWindow: InfoWindow(
          title: report.nomeCategoria,
          snippet: "$emojiStatus ${report.nomeStatus} • Toque para ver >", 
          onTap: () {
            // CORREÇÃO 2: Esconde o balão (InfoWindow) IMEDIATAMENTE antes de abrir o modal.
            // Isso impede que ele fique "atrás" do botão fechar.
            _mapController?.hideMarkerInfoWindow(MarkerId(markerIdUnico));

            try {
              final reportAtual = _reports.firstWhere(
                (r) => r.id == report.id,
                orElse: () => report,
              );
              _exibirDetalhesDoReport(reportAtual);
            } catch (e) {
              _exibirDetalhesDoReport(report);
            }
          },
        ),
      );
    }).toSet();
  }

  // Função auxiliar para definir o emoji baseado no status
  String _obterEmojiStatus(String statusNome) {
    String status = statusNome.toLowerCase();
    if (status.contains('pendente') || status.contains('aberto')) {
      return "🔴"; // Vermelho
    } else if (status.contains('andamento') || status.contains('analise')) {
      return "🟡"; // Amarelo
    } else if (status.contains('concluído') || status.contains('resolvido')) {
      return "🟢"; // Verde
    } else if (status.contains('inválido')) {
      return "⚪"; // Cinza/Branco
    }
    return "🔵"; // Azul padrão
  }

  // Lógica de cores baseada no STATUS para o Ícone (Pino)
  BitmapDescriptor _definirCorDoIcone(Report report) {
    Color cor;
    String status = report.nomeStatus.toLowerCase();
    
    if (status.contains('pendente') || status.contains('aberto')) {
      cor = Colors.red;
    } else if (status.contains('andamento') || status.contains('analise')) {
      cor = Colors.orange;
    } else if (status.contains('concluído') || status.contains('resolvido')) {
      cor = Colors.green;
    } else if (status.contains('inválido')) {
      cor = Colors.grey;
    } else {
      switch (report.nomeCategoria.toLowerCase()) {
        case 'buraco': cor = Colors.orange; break;
        case 'iluminação': cor = Colors.yellow; break;
        case 'lixo': cor = Colors.green; break;
        default: cor = Colors.blue;
      }
    }
    
    return BitmapDescriptor.defaultMarkerWithHue(_converterCorParaHue(cor));
  }

  double _converterCorParaHue(Color color) {
    if (color == Colors.red) return BitmapDescriptor.hueRed;
    if (color == Colors.orange) return BitmapDescriptor.hueOrange;
    if (color == Colors.yellow) return BitmapDescriptor.hueYellow;
    if (color == Colors.green) return BitmapDescriptor.hueGreen;
    if (color == Colors.blue) return BitmapDescriptor.hueBlue;
    if (color == Colors.grey) return BitmapDescriptor.hueRose;
    return BitmapDescriptor.hueAzure;
  }

  // --- Exibição de Detalhes ---

  void _exibirDetalhesDoReport(Report report) {
    bool temImagem = report.urlImagem.isNotEmpty;
    Color corStatus = _obterCorStatus(report.nomeStatus);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          report.nomeCategoria,
                          style: const TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A5F)
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const Divider(),
                  
                  if (temImagem)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          report.urlImagem,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_,__,___) => Container(
                            height: 150,
                            color: Colors.grey[200],
                            child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                          ),
                          loadingBuilder: (context, child, loading) {
                            if (loading == null) return child;
                            return Container(
                              height: 200,
                              color: Colors.grey[100],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loading.expectedTotalBytes != null
                                      ? loading.cumulativeBytesLoaded / loading.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  _linhaInfo(Icons.location_on, report.endereco),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      const Icon(Icons.info, size: 20, color: Color(0xFF1E3A5F)),
                      const SizedBox(width: 8),
                      const Text("Status: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: corStatus.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: corStatus),
                        ),
                        child: Text(
                          report.nomeStatus,
                          style: TextStyle(
                            color: corStatus,
                            fontWeight: FontWeight.bold,
                            fontSize: 12
                          ),
                        ),
                      )
                    ],
                  ),

                  if (report.descricao.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _linhaInfo(Icons.description, report.descricao),
                  ],
                  const SizedBox(height: 8),
                  _linhaInfo(Icons.calendar_month, report.dataSimples),
                  
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A5F),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Fechar"),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Color _obterCorStatus(String statusNome) {
    String status = statusNome.toLowerCase();
    if (status.contains('pendente') || status.contains('aberto')) return Colors.red;
    if (status.contains('andamento') || status.contains('analise')) return Colors.orange;
    if (status.contains('concluído') || status.contains('resolvido')) return Colors.green;
    return Colors.blue;
  }

  Widget _linhaInfo(IconData icon, String text, {bool isBold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1E3A5F)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _abrirModalNovoReport() async {
    await mostrarModal(context, widget.usuarioID);
    
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_disposed) _carregarReports();
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
            elevation: 4,
            title: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfileScreen()),
                    );
                    _carregarFotoUsuario();
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    backgroundImage: (fotoUrl != null) ? NetworkImage(fotoUrl!) : null,
                    child: (fotoUrl == null) 
                        ? const Icon(Icons.person, color: Colors.white) 
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.nomeUsuario,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _carregarReports,
              )
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // MAPA
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _posicaoInicial,
              zoom: 16,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            markers: _markers,
            onMapCreated: (controller) => _mapController = controller,
          ),
          
          // Contador de Reports
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
              ),
              child: Text(
                "${_reports.length} problemas encontrados",
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF1E3A5F)
                ),
              ),
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // Controles de Zoom e Localização
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "zoom_in",
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Color(0xFF1E3A5F)),
                  onPressed: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: "zoom_out",
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: Color(0xFF1E3A5F)),
                  onPressed: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: "my_loc",
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Color(0xFF1E3A5F)),
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.newLatLng(_posicaoInicial));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: _abrirModalNovoReport,
          backgroundColor: Colors.redAccent,
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
          label: const Text("REPORTAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}