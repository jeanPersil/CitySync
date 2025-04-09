import 'package:flutter/material.dart';

class Tela_config extends StatelessWidget {
  const Tela_config({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          children: [Text("Tela de configurações")],
        ),
      ),
    );
  }
}
