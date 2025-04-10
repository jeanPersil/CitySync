import 'package:flutter/material.dart';

class Tela_config extends StatelessWidget {
  const Tela_config({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = false; // Estado fictício para o tema
    String selectedLanguage = 'pt'; // Estado fictício para o idioma

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
              value: isDarkMode,
              onChanged: (bool value) {
                //lógica par alternar o tema
                
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma'),
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              onChanged: (String? newValue) {
                //lógica pra trocar o idioma
                
              },
              items: const [
                DropdownMenuItem(
                  value: 'pt',
                  child: Text('Português'),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text('Inglês'),
                ),
                // Adicione mais idiomas
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              
            },
          ),
        ],
      ),
    );
  }
}
