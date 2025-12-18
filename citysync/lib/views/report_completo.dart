import 'package:citysync/model/model_report.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportCompleto extends StatelessWidget {
  const ReportCompleto({super.key, required this.report});

  final Report report;

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
      backgroundColor: const Color(0xFF0A1D3D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A5F),
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Row(
          children: [
            Icon(Icons.assignment, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Report Completo',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
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
                icon: Icons.location_on_outlined,
                label: "Endereço",
                value: report.endereco,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.category_outlined,
                label: "Categoria",
                value: report.nomeCategoria,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.calendar_today_outlined,
                label: "Data de criação",
                value: formatarDataHora(report.dataCriacao),
              ),
              const SizedBox(height: 20),
              const Text(
                "Descrição",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                report.descricao,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),
              (report.urlImagem.isNotEmpty)
                  ? Image.network(report.urlImagem)
                  : const Text("Nehuma imagem esta anexada a esse report",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
