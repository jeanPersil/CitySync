import 'package:flutter/foundation.dart';
import 'package:citysync/model/modelReport.dart';
import 'package:citysync/services/reports.dart';

const int kPageSize = 10;

class ProblemasReportController extends ChangeNotifier {
  final ReportApiService reportApiService;
  final String usuarioID;

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

  Future<void> loadReports({bool refresh = false}) async {
    if (_isLoadingMore) return;

    if (refresh) {
      _reports.clear();
      _currentPage = 1;
      _hasMoreData = true;
      _error = null;
      _isInitialLoading = true;
      notifyListeners();
    } else if (_isInitialLoading) {
      _isInitialLoading = true;
      notifyListeners();
    } else {
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final newReports =
          await reportApiService.obterListaReports(usuarioID, _currentPage);

      _reports.addAll(newReports);
      _currentPage++;
      _isInitialLoading = false;
      _isLoadingMore = false;

      if (newReports.length < kPageSize) _hasMoreData = false;

      notifyListeners();
      
    } catch (e) {
      _isInitialLoading = false;
      _isLoadingMore = false;
      _error = "Erro ao carregar reports: $e";
      notifyListeners();
    }
  }
}
