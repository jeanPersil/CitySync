import 'package:citysync/services/testeAPI.dart';
import 'package:citysync/views/reportaProblema.dart';
import 'package:citysync/widgets/botaoCategoria.dart';
import 'package:citysync/widgets/modal_Pagina_inicial.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class Telaprincipal extends StatefulWidget {
  Telaprincipal({super.key});

  @override
  State<Telaprincipal> createState() => _TelaprincipalState();
}

class _TelaprincipalState extends State<Telaprincipal> {
  final LatLng _senaiFeiraDeSantana = const LatLng(-12.2663, -38.9458);

   final api = TesteApi();

   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: const [
            Icon(Icons.people_alt_outlined, color: Colors.white),
            SizedBox(width: 8),
            Text("denis",
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: Colors.white)),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(color: Colors.white),
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
        onPressed: () async {
    final api = TesteApi();
    try {
      final mensagem = await api.requisicao();
      print(mensagem); 
    } catch (e) {
      print('Erro ao chamar API: $e');
    }
  },
        backgroundColor: Colors.redAccent,
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
