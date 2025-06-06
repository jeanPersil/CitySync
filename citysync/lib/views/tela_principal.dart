import 'package:citysync/services/teste_api.dart';
import 'package:citysync/widgets/modal_pagina_inicial.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class Telaprincipal extends StatefulWidget {
  const Telaprincipal({super.key});

  @override
  State<Telaprincipal> createState() => _TelaprincipalState();
}

class _TelaprincipalState extends State<Telaprincipal> {
  final LatLng _senaiFeiraDeSantana = const LatLng(-12.2663, -38.9458);

   final api = TesteApi();

   
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Color(0xFF1E3A5F),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[850] : Color(0xFF1E3A5F),
        title: Row(
          children: [
            Icon(Icons.people_alt_outlined, color: isDark ? Colors.white : Colors.white),
            const SizedBox(width: 8),
            Text(
              "denis",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : Colors.white,
                ),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _senaiFeiraDeSantana,
                    zoom: 18,
                  ),
                  mapType: MapType.normal,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => mostrarModal(context),
        backgroundColor: isDark ? Colors.red[400] : Colors.redAccent,
        icon: const Icon(Icons.dangerous_sharp, color: Colors.white),
        label: const Text(
          'Reportar um problema',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
