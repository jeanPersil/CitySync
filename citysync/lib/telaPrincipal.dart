import 'package:citysync/reportaProblema.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Telaprincipal extends StatelessWidget {
  Telaprincipal({super.key});


  final LatLng _senaiFeiraDeSantana = const LatLng(-12.2663, -38.9458);

  void selecionar(){

  }

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
        child: Stack(
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
            DraggableScrollableSheet(
              initialChildSize: 0.40,
              minChildSize: 0.2,
              maxChildSize: 0.5,
              builder: (context, scrollController) {
                return Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 4,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.construction),
                                    style: IconButton.styleFrom(
                                    ),
                                    onPressed: () {},
                                    iconSize: 40,
                                    color: Colors.black,

                                    
                                  ),
                                 
                                  Text("Buraco",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),

                              //----------------------

                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.light),
                                    iconSize: 40,
                                    color: Colors.black,
                                  ),
                                  Text(
                                    'ILuminação',
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),

                              //----------------------

                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.delete_outlined),
                                    iconSize: 40,
                                    color: Colors.black,
                                  ),
                                  Text(
                                    'Lixo',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),

                              //---------

                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.traffic_outlined),
                                    iconSize: 40,
                                    color: Colors.black,
                                  ),
                                  Text(
                                    'Semafaro',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),

                              //-------

                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.water),
                                    iconSize: 40,
                                    color: Colors.black,
                                  ),
                                  Text(
                                    'Vazamento/Esgoto',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),

                              //-------------------

                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.car_repair),
                                    iconSize: 40,
                                    color: Colors.black,
                                  ),
                                  Text(
                                    'Transporte',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),

                              //------------

                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.menu),
                                    iconSize: 40,
                                    color: Colors.black,
                                  ),
                                  Text(
                                    'Outros',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () {}, child: Text('Reportar probelma'))
                      ],
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }
}