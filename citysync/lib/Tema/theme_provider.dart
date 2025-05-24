import 'package:flutter/material.dart';
import 'tema.dart'; // ajuste o caminho conforme sua estrutura de pastas

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeData get themeData => _themeData; // <- CORRIGIDO AQUI

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    themeData = _themeData == lightMode ? darkMode : lightMode;
  }

  bool get isDarkMode => _themeData == darkMode;
}
