import 'package:citysync/views/login.dart';
import 'package:citysync/views/suporte.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A5F), 
              Color(0xFF1E3A5F),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Configurações',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                iconTheme: const IconThemeData(
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Idioma
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white.withValues(alpha: 0.9),
                      child: ListTile(
                        leading: Icon(Icons.language, color: Colors.blueGrey[700]),
                        title: Text(
                          'Idioma',
                          style: TextStyle(
                            color: Colors.blueGrey[900],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: DropdownButton<String>(
                          value: _selectedLanguage,
                          dropdownColor: Colors.white, 
                          style: TextStyle(
                            color: Colors.blueGrey[900],
                            fontSize: 16,
                          ),
                          iconEnabledColor: Colors.blueGrey[700], 
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
                    
                    // Política de Privacidade
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white.withValues(alpha: 0.9),
                      child: ListTile(
                        leading: Icon(Icons.policy, color: Colors.blueGrey[700]),
                        title: Text(
                          'Política de Privacidade',
                          style: TextStyle(
                            color: Colors.blueGrey[900],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.blueGrey[400]),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PoliticaPrivacidadePage()),
                          );
                        },
                      ),
                    ),

                    // Suporte e Feedback
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white.withValues(alpha: 0.9),
                      child: ListTile(
                        leading: Icon(Icons.help_outline, color: Colors.blueGrey[700]),
                        title: Text(
                          'Suporte e Feedback',
                          style: TextStyle(
                            color: Colors.blueGrey[900],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.blueGrey[400]),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SuportePage()),
                          );
                        },
                      ),
                    ),
                   
                    // Sair
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.red[700]!.withValues(alpha: 0.9),
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
                        onTap: _logout,
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
  
  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const TelaLogin()),
      (Route<dynamic> route) => false,
    );
  }
}