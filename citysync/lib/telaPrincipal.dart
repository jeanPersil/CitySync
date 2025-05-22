import 'package:citysync/reportaProblema.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Telaprincipal extends StatelessWidget {
  Telaprincipal({super.key});

  final LatLng _senaiFeiraDeSantana = const LatLng(-12.2663, -38.9458);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: const [
            Icon(
              Icons.people_alt_outlined,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              "denis",
              style:
                  TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
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
                decoration: const BoxDecoration(color: Colors.white),
                child: GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: _senaiFeiraDeSantana, zoom: 18),
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
                          builder: (context) =>tela_report()),
                    );
                  },
                  child: const Text(
                    "Reportar problema",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text(
                    "Ver problemas",
                    style: TextStyle(color: Colors.black),
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
