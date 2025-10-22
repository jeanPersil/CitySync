import 'package:citysync/model/model_report.dart';
import 'package:citysync/services/reports.dart';
import 'package:citysync/views/report_completo.dart';
import 'package:citysync/widgets/card_problema.dart';
import 'package:flutter/material.dart';

class ProblemasReport extends StatefulWidget {
  const ProblemasReport({
    super.key,
    required this.nomeUsuario,
    required this.usuarioID,
  });

  final String nomeUsuario;
  final String usuarioID;

  @override
  State<ProblemasReport> createState() => _ProblemasReportState();
}

class _ProblemasReportState extends State<ProblemasReport>
    with SingleTickerProviderStateMixin {
  final ReportApiService _reportApiService = ReportApiService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Cache de cores baseadas no tema para melhor performance
  late Color _backgroundColor;
  late Color _appBarColor;
  late Color _cardColor;
  late Color _textColor;
  late Color _secondaryTextColor;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache das cores baseadas no tema atual
    _cacheThemeColors();
  }

  void _cacheThemeColors() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    _backgroundColor = isDark ? Colors.grey[900]! : const Color(0xFF0A1D3D);
    _appBarColor = isDark ? Colors.grey[850]! : const Color(0xFF1E3A5F);
    _cardColor = isDark 
        ? Colors.grey[800]! 
        : const Color(0xFF1E3A5F).withValues(alpha: 0.8);
    _textColor = Colors.white; // Sempre branco em ambos os temas
    _secondaryTextColor = Colors.white70; // Sempre white70 em ambos os temas
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {});
  }

  void _navigateToReportDetail(Report report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportCompleto(report: report),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth < 600 ? screenWidth * 0.9 : screenWidth * 0.5;
    final horizontalPadding = screenWidth < 600 ? 16.0 : (screenWidth - containerWidth) / 2;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(containerWidth),
            Expanded(
              child: _buildReportsList(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _appBarColor,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.4),
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
              color: const Color(0xFF20C997).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_alt_outlined,
              color: _textColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.nomeUsuario,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _textColor,
              fontSize: 18,
              shadows: _appBarColor == const Color(0xFF1E3A5F) // Apenas se não for dark
                  ? [
                      const Shadow(
                        blurRadius: 4,
                        color: Colors.black,
                        offset: Offset(0, 1),
                      )
                    ]
                  : [],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _textColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.refresh, color: _textColor, size: 22),
          ),
          onPressed: _handleRefresh,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader(double containerWidth) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: containerWidth,
          padding: const EdgeInsets.all(20.0),
          margin: const EdgeInsets.only(bottom: 20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF20C997),
                Color(0xFF1A9E7A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF20C997).withValues(alpha: 0.4),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  "📋 Reports Enviados",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black45,
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
    );
  }

  Widget _buildReportsList() {
    return FutureBuilder<List<Report>>(
      future: _reportApiService.obterListaReports(widget.usuarioID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        } else if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        return _buildReportsListView(snapshot.data!);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF20C997)),
          ),
          const SizedBox(height: 16),
          Text(
            "Carregando seus reports...",
            style: TextStyle(
              color: _secondaryTextColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text(
            "Erro ao carregar reports: $error",
            style: TextStyle(
              color: _secondaryTextColor,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _handleRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text("Tentar Novamente"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF20C997),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      color: _secondaryTextColor,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Nenhum problema reportado ainda",
                      style: TextStyle(
                        color: _secondaryTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Seus reports aparecerão aqui quando você fizer sua primeira solicitação",
                      style: TextStyle(
                        color: _secondaryTextColor.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportsListView(List<Report> reports) {
    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildReportItem(report, index);
      },
    );
  }

  Widget _buildReportItem(Report report, int index) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 0.5 + (index * 0.1)),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.1 * index, 1.0, curve: Curves.easeOut),
      )),
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.1 * index, 1.0, curve: Curves.easeIn),
        )),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: InkWell(
            onTap: () => _navigateToReportDetail(report),
            borderRadius: BorderRadius.circular(12),
            child: CardPRoblema(report: report),
          ),
        ),
      ),
    );
  }
}