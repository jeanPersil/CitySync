import 'package:flutter/material.dart';
import 'package:citysync/model/modelReport.dart';

class CardPRoblema extends StatelessWidget {
  CardPRoblema({super.key, required this.report});

  final Report report;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return Colors.orange;
      case 'em andamento':
        return Colors.blue;
      case 'resolvido':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFEDEDED),
          border: Border(
            left: BorderSide(
              color: _getStatusColor(report.nomeStatus),
              width: 7,
            ),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.nomeCategoria,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              report.dataCriacao,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: _getStatusColor(report.nomeStatus),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                report.nomeStatus,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
