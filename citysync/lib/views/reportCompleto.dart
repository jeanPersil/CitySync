import 'package:citysync/model/modelReport.dart';
import 'package:flutter/material.dart';

class ReportCompleto extends StatelessWidget {
  ReportCompleto({super.key, required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Completo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data: ${report.dataCriacao}'),
            SizedBox(height: 8.0),
            Text('Título: ${report.nomeCategoria}'),
            SizedBox(height: 8.0),
            Text('Descrição'),
            Text(report.descricao),
            SizedBox(height: 8.0),
            Text('Endereço: ${report.endereco}'),
            SizedBox(height: 8.0),
            Text('Status: ${report.nomeStatus}'),
            SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}
