import 'package:flutter/material.dart';

class ReportLoadingIndicator extends StatelessWidget {
  const ReportLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF20C997)),
      ),
    );
  }
}
