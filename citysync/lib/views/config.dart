import 'package:citysync/views/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citysync/Tema/theme_provider.dart';

class TelaConfig extends StatelessWidget {
  const TelaConfig({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    String selectedLanguage = 'pt';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Tema Escuro'),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma'),
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              onChanged: (String? newValue) {
                // lógica para trocar o idioma
              },
              items: const [
                DropdownMenuItem(
                  value: 'pt',
                  child: Text('Português'),
                ),
                DropdownMenuItem(
                  value: 'dv',
                  child: Text('Em desenvolvimento'),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
               Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => TelaLogin()),
                (Route<dynamic> route) => false, 
              );
            },
          ),
        ],
      ),
    );
  }
}
