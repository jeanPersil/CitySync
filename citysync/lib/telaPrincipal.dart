import 'package:citysync/reportaProblema.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Telaprincipal extends StatelessWidget {
  Telaprincipal({super.key});

  final LatLng _senaiFeiraDeSantana = const LatLng(-12.2663, -38.9458);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textColor = colorScheme.onBackground;  // texto com cor certa para o fundo


    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Row(
          children: [
            Icon(
              Icons.people_alt_outlined,
              color: colorScheme.onPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              "denis",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.background,
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportProblemPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                  ),
                  child: Text(
                    "Reportar problema",
                    style: TextStyle(color: colorScheme.onSecondary),
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                  ),
                  child: Text(
                    "Ver problemas",
                    style: TextStyle(color: colorScheme.onSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
