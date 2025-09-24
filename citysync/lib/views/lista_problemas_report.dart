import 'package:citysync/model/modelReport.dart';
import 'package:citysync/services/reports.dart';
import 'package:citysync/views/reportCompleto.dart';
import 'package:citysync/widgets/cardProblema.dart';
import 'package:flutter/material.dart';

class ProblemasReport extends StatefulWidget {
  ProblemasReport({
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
  final ReportApiService reportApiService = ReportApiService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Função para obter cores baseadas no tema
  Color _getBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.grey[900]!
        : const Color(0xFF0A1D3D);
  }

  Color _getAppBarColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.grey[850]!
        : const Color(0xFF1E3A5F);
  }

  Color _getCardColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.grey[800]!
        : const Color(0xFF1E3A5F).withOpacity(0.8);
  }

  Color _getTextColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark ? Colors.white : Colors.white;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.white70
        : Colors.white70;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth =
        (screenWidth < 600) ? screenWidth * 0.9 : screenWidth * 0.5;
    final horizontalPadding =
        (screenWidth < 600) ? 16.0 : (screenWidth - containerWidth) / 2;

    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: _getAppBarColor(context),
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
              child: Icon(Icons.people_alt_outlined,
                  color: _getTextColor(context), size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              widget.nomeUsuario,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _getTextColor(context),
                fontSize: 18,
                shadows: isDark
                    ? []
                    : [
                        const Shadow(
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
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _getTextColor(context).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(Icons.refresh, color: _getTextColor(context), size: 22),
            ),
            onPressed: () {
              setState(() {});
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header com animação
            SlideTransition(
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
                        color: const Color(0xFF20C997).withOpacity(0.4),
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
            ),

            /// Lista de reports
            Expanded(
              child: FutureBuilder<List<Report>>(
                future: reportApiService.obterListaReports(widget.usuarioID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF20C997)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Carregando seus reports...",
                            style: TextStyle(
                                color: _getSecondaryTextColor(context),
                                fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.redAccent, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            "Erro ao carregar reports: ${snapshot.error}",
                            style: TextStyle(
                                color: _getSecondaryTextColor(context),
                                fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {});
                            },
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
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                                  color: _getCardColor(context),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.inbox_outlined,
                                        color: _getSecondaryTextColor(context),
                                        size: 64),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Nenhum problema reportado ainda",
                                      style: TextStyle(
                                        color: _getSecondaryTextColor(context),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Seus reports aparecerão aqui quando você fizer sua primeira solicitação",
                                      style: TextStyle(
                                        color: _getSecondaryTextColor(context)
                                            .withOpacity(0.8),
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

                  final reports = snapshot.data!;
                  return ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 0.5 + (index * 0.1)),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _animationController,
                          curve:
                              Interval(0.1 * index, 1.0, curve: Curves.easeOut),
                        )),
                        child: FadeTransition(
                          opacity: Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(0.1 * index, 1.0,
                                curve: Curves.easeIn),
                          )),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            child: InkWell(
                              onTap: () {
                                // Navega para a tela ReportCompleto
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReportCompleto(
                                      report: report,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(
                                  12), // Opcional: para matchar o borderRadius do card
                              child: CardPRoblema(report: report),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
