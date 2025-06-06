import 'package:citysync/views/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citysync/Tema/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CitySync',
      theme: themeProvider.themeData,
      home: TelaLogin(), 
    );
  }
}
