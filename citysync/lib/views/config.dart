import 'package:citysync/views/login.dart';
import 'package:citysync/views/suporte.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:citysync/Tema/theme_provider.dart';
import 'package:citysync/views/politica_privacidade.dart';


class TelaConfig extends StatefulWidget {
  const TelaConfig({super.key});

  @override
  State<TelaConfig> createState() => _TelaConfigState();
}

class _TelaConfigState extends State<TelaConfig> {
  String _selectedLanguage = 'pt'; 

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDark ? Colors.grey[850]! : Color(0xFF1E3A5F), 
              isDark ? Colors.grey[900]! : Color(0xFF1E3A5F) 
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'Configurações',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: isDark ? Colors.grey[800] : Colors.white.withValues(alpha: 0.9),
                      child: ListTile(
                        leading: Icon(Icons.brightness_6, color: isDark ? Colors.white : Colors.blueGrey[700]),
                        title: Text(
                          'Tema Escuro',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.blueGrey[900],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                          },
                          thumbColor: WidgetStateProperty.resolveWith<Color>(
                            (states) {
                              if (states.contains(WidgetState.selected)) {
                                return const Color(0xFF20C997); // cor quando o switch está ativo ✅
                              }
                              return Colors.grey.shade400; // cor quando está desativado
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: isDark ? Colors.grey[800] : Colors.white.withValues(alpha: 0.9),
                      child: ListTile(
                        leading: Icon(Icons.language, color: isDark ? Colors.white : Colors.blueGrey[700]),
                        title: Text(
                          'Idioma',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.blueGrey[900],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: DropdownButton<String>(
                          value: _selectedLanguage,
                          dropdownColor: isDark ? Colors.grey[700] : Colors.white, 
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.blueGrey[900],
                            fontSize: 16,
                          ),
                          iconEnabledColor: isDark ? Colors.white : Colors.blueGrey[700], 
                          underline: const SizedBox(), 
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedLanguage = newValue!; 
                            });
                            
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
                    ),
                    
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: isDark ? Colors.grey[800] : Colors.white.withValues(alpha: 0.9),
                      child: ListTile(
                        leading: Icon(Icons.policy, color: isDark ? Colors.white : Colors.blueGrey[700]),
                        title: Text(
                          'Política de Privacidade',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.blueGrey[900],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: isDark ? Colors.white54 : Colors.blueGrey[400]),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PoliticaPrivacidadePage()),
                          );
                        },
                      ),
                    ),

                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: isDark ? Colors.grey[800] : Colors.white.withValues(alpha: 0.9),
                      child: ListTile(
                        leading: Icon(Icons.help_outline, color: isDark ? Colors.white : Colors.blueGrey[700]),
                        title: Text(
                          'Suporte e Feedback',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.blueGrey[900],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: isDark ? Colors.white54 : Colors.blueGrey[400]),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SuportePage()),
                          );
                        },
                      ),
                    ),
                   
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: isDark ? Colors.red[900]!.withValues(alpha: 0.8) : Colors.red[700]!.withValues(alpha: 0.9), // Cor de destaque para Logout
                      child: ListTile(
                        leading: const Icon(Icons.exit_to_app, color: Colors.white),
                        title: const Text(
                          'Sair',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white54),
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const TelaLogin()),
                            (Route<dynamic> route) => false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
