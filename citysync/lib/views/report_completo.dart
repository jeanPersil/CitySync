import 'package:citysync/model/modelReport.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportCompleto extends StatelessWidget {
  ReportCompleto({super.key, required this.report});

  final Report report;

  Color _getBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.grey[900]!
        : const Color(0xFF0A1D3D); // fundo azul escuro
  }

  Color _getAppBarColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.grey[850]!
        : const Color(0xFF1E3A5F); // azul intermediário
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

  String formatarDataHora(String dataCriacao) {
    try {
      final dateTime = DateTime.parse(dataCriacao).toLocal();
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return dataCriacao;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: _getAppBarColor(context),
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.assignment, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              'Report Completo',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _getTextColor(context),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A5F).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                context,
                icon: Icons.location_on_outlined,
                label: "Endereço",
                value: report.endereco,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                icon: Icons.category_outlined,
                label: "Categoria",
                value: report.nomeCategoria,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                icon: Icons.calendar_today_outlined,
                label: "Data de criação",
                value: formatarDataHora(report.dataCriacao),
              ),
              const SizedBox(height: 20),
              Text(
                "Descrição",
                style: TextStyle(
                  color: _getTextColor(context),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                report.descricao,
                style: TextStyle(
                  color: _getSecondaryTextColor(context),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _getTextColor(context), size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: _getSecondaryTextColor(context),
                fontSize: 15,
              ),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(context),
                  ),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
