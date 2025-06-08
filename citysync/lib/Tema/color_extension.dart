//color_extension.dart
import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color withOpacidade(double opacity) {
    final a = (opacity * 255).round();
    return withValues(
      red: r.toDouble(),
      green: g.toDouble(),
      blue: b.toDouble(),
      alpha: a.toDouble(),
    );
  }
}
