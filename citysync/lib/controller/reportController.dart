import 'package:flutter/foundation.dart';
import 'package:citysync/model/modelReport.dart';
import 'package:citysync/services/reports.dart';

const int kPageSize = 10;

class ProblemasReportController extends ChangeNotifier {
  final ReportApiService reportApiService;
  final String usuarioID;

  // Flag crítica para controlar dispose
  bool _disposed = false;

  ProblemasReportController({
    required this.reportApiService,
    required this.usuarioID,
  });

  final List<Report> _reports = [];
  List<Report> get reports => _reports;

  int _currentPage = 1;
  bool _isInitialLoading = true;
  bool get isInitialLoading => _isInitialLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _hasMoreData = true;
  bool get hasMoreData => _hasMoreData;

  String? _error;
  String? get error => _error;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  // Método auxiliar para atualizar estado com segurança
  void _safeSetState(VoidCallback fn) {
    if (!_disposed) {
      fn();
      notifyListeners();
    }
  }

  Future<void> loadReports({bool refresh = false}) async {
    // Verifica se foi disposed antes de começar
    if (_disposed) return;

    // Evita múltiplas requisições simultâneas
    if (_isLoadingMore) return;

    if (refresh) {
      _safeSetState(() {
        _reports.clear();
        _currentPage = 1;
        _hasMoreData = true;
        _error = null;
        _isInitialLoading = true;
      });
    } else if (_isInitialLoading) {
      _safeSetState(() {
        _isInitialLoading = true;
      });
    } else {
      _safeSetState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final newReports =
          await reportApiService.obterListaReports(usuarioID, _currentPage);

      // CRÍTICO: Verifica se foi disposed após operação assíncrona
      if (_disposed) return;

      _safeSetState(() {
        _reports.addAll(newReports);
        _currentPage++;
        _isInitialLoading = false;
        _isLoadingMore = false;

        if (newReports.length < kPageSize) {
          _hasMoreData = false;
        }
      });
      
    } catch (e) {
      // CRÍTICO: Verifica se foi disposed antes de atualizar erro
      if (_disposed) return;

      _safeSetState(() {
        _isInitialLoading = false;
        _isLoadingMore = false;
        _error = "Erro ao carregar reports: $e";
      });
    }
  }

  // Método adicional para limpar erro
  void clearError() {
    _safeSetState(() {
      _error = null;
    });
  }

  // Método adicional para adicionar report manualmente (útil após criar novo)
  void addReport(Report newReport) {
    if (_disposed) return;
    
    _safeSetState(() {
      _reports.insert(0, newReport);
    });
  }

  // Método adicional para remover report
  void removeReport(String reportId) {
    if (_disposed) return;
    
    _safeSetState(() {
      _reports.removeWhere((report) => report.id == reportId);
    });
  }

  // Método adicional para atualizar report
  void updateReport(Report updatedReport) {
    if (_disposed) return;
    
    _safeSetState(() {
      final index = _reports.indexWhere((r) => r.id == updatedReport.id);
      if (index != -1) {
        _reports[index] = updatedReport;
      }
    });
  }
}