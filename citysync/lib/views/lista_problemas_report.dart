import 'package:citysync/controller/report_controller.dart';
import 'package:citysync/services/reports.dart';
import 'package:citysync/widgets/lista_reports.dart';
import 'package:citysync/widgets/report_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProblemasReport extends StatelessWidget {
  final String nomeUsuario;
  final String usuarioID;

  const ProblemasReport({
    super.key,
    required this.nomeUsuario,
    required this.usuarioID,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProblemasReportController(
        reportApiService: ReportApiService(),
        usuarioID: usuarioID,
      )..loadReports(),
      child: _ProblemasReportView(nomeUsuario: nomeUsuario),
    );
  }
}

class _ProblemasReportView extends StatefulWidget {
  final String nomeUsuario;
  const _ProblemasReportView({required this.nomeUsuario});

  @override
  State<_ProblemasReportView> createState() => _ProblemasReportViewState();
}

class _ProblemasReportViewState extends State<_ProblemasReportView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final controller = context.read<ProblemasReportController>();
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !controller.isLoadingMore &&
        controller.hasMoreData) {
      controller.loadReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProblemasReportController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth =
        (screenWidth < 600) ? screenWidth * 0.9 : screenWidth * 0.5;
    final horizontalPadding =
        (screenWidth < 600) ? 16.0 : (screenWidth - containerWidth) / 2;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1D3D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF20C997).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_alt_outlined,
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
                      blurRadius: 4, color: Colors.black, offset: Offset(0, 1))
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
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh, color: Colors.white, size: 22),
            ),
            onPressed: () => controller.loadReports(refresh: true),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ReportHeader(
              fadeAnimation: _fadeAnimation,
              slideAnimation: _slideAnimation,
              containerWidth: containerWidth,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.loadReports(refresh: true),
                backgroundColor: const Color(0xFF1E3A5F),
                color: const Color(0xFF20C997),
                child: ReportListView(
                  controller: controller,
                  scrollController: _scrollController,
                  fadeAnimation: _fadeAnimation,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
