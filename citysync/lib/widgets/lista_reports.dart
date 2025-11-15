import 'package:citysync/controller/report_controller.dart';
import 'package:citysync/views/report_completo.dart';
import 'package:citysync/widgets/card_problema.dart';
import 'package:citysync/widgets/report_empty_view.dart';
import 'package:citysync/widgets/report_error_view.dart';
import 'package:citysync/widgets/report_loading_indicator.dart';
import 'package:flutter/material.dart';

class ReportListView extends StatelessWidget {
  final ProblemasReportController controller;
  final ScrollController scrollController;
  final Animation<double> fadeAnimation;

  const ReportListView({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.isInitialLoading) return const ReportLoadingIndicator();
    if (controller.error != null) {
      return ReportErrorView(onRetry: () => controller.loadReports(refresh: true));
    }
    if (controller.reports.isEmpty) {
      return ReportEmptyView(fadeAnimation: fadeAnimation);
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: controller.reports.length + (controller.hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == controller.reports.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF20C997)),
              ),
            ),
          );
        }

        final report = controller.reports[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReportCompleto(report: report)),
            ),
            borderRadius: BorderRadius.circular(12),
            child: CardPRoblema(report: report),
          ),
        );
      },
    );
  }
}
