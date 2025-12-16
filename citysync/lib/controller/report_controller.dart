import 'package:flutter/foundation.dart';
import 'package:citysync/model/model_report.dart';
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
  
  // Inicializa como false, o método loadReports define quando vira true
  bool _isInitialLoading = false; 
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
    if (_isLoadingMore && !refresh) return;

    _safeSetState(() {
      _error = null; // Limpa erros anteriores
      
      if (refresh) {
        _reports.clear();
        _currentPage = 1;
        _hasMoreData = true;
        _isInitialLoading = true;
      } else if (_reports.isEmpty) {
        _isInitialLoading = true;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final newReports = await reportApiService.obterListaReports(usuarioID, _currentPage);

      // CRÍTICO: Verifica se foi disposed após operação assíncrona
      if (_disposed) return;

      _safeSetState(() {
        _reports.addAll(newReports);
        
        // Só incrementa a página se vieram dados
        if (newReports.isNotEmpty) {
           _currentPage++;
        }

        _isInitialLoading = false;
        _isLoadingMore = false;

        // Se vieram menos itens que o tamanho da página, acabou os dados
        if (newReports.length < kPageSize) {
          _hasMoreData = false;
        }
      });
      
    } catch (e) {
      // CRÍTICO: Verifica se foi disposed antes de atualizar erro
      if (_disposed) return;
      
      debugPrint("Erro controller: $e"); // Log para o desenvolvedor

      _safeSetState(() {
        _isInitialLoading = false;
        _isLoadingMore = false;
        // Mensagem amigável para a UI, mantendo o erro técnico no console
        _error = "Não foi possível carregar os dados. Tente novamente.";
      });
    }
  }

  void clearError() {
    _safeSetState(() {
      _error = null;
    });
  }

  void addReport(Report newReport) {
    if (_disposed) return;
    _safeSetState(() {
      _reports.insert(0, newReport);
    });
  }

  // CORREÇÃO IMPORTANTE AQUI:
  // Mudamos o tipo para dynamic para evitar erro de comparação entre Int e String
  void removeReport(dynamic reportId) {
    if (_disposed) return;
    
    _safeSetState(() {
      // .toString() garante que comparamos texto com texto, evitando o erro
      _reports.removeWhere((report) => report.id.toString() == reportId.toString());
    });
  }

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