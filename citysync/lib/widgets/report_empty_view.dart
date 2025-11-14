import 'package:flutter/material.dart';

class ReportEmptyView extends StatelessWidget {
  final Animation<double> fadeAnimation;

  const ReportEmptyView({super.key, required this.fadeAnimation});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inbox_outlined, color: Colors.white70, size: 64),
          SizedBox(height: 16),
          Text(
            "Nenhum problema reportado ainda",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            "Seus reports aparecerão aqui quando você fizer sua primeira solicitação",
            style: TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
