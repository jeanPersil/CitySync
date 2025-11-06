import 'package:flutter/material.dart';

class ReportErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const ReportErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          const Text(
            "Erro ao carregar reports.",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text("Tentar Novamente"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF20C997),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
