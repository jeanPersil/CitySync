import 'package:citysync/views/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citysync/Tema/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://hqyyltlpltrxvikkncjf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhxeXlsdGxwbHRyeHZpa2tuY2pmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ1MDkzODcsImV4cCI6MjA3MDA4NTM4N30.cFFTNe6MwbXpu9H5hMM0KovKoNHlV0cxWMfWLNsvh0k',
  );
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
        home: TelaLogin());
  }
}
