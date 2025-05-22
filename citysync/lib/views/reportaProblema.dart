import 'package:citysync/homePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ReportProblemPage extends StatefulWidget {
  @override
  _ReportProblemPageState createState() => _ReportProblemPageState();
}

class _ReportProblemPageState extends State<ReportProblemPage> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController problemController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  final LatLng _initialPosition = LatLng(-12.2664, -38.9668);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.blue[900]),
                    ),
                    SizedBox(width: 10),
                    Text('IWIN', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              SizedBox(
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: _initialPosition,
                      initialZoom: 16.0,
                      onTap: (tapPosition, location) {
                        print('Local selecionado: \$location');
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Endereço Selecionado',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 4),
                    TextField(
                      controller: addressController,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Digite o endereço',
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Qual problema gostaria de relatar?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 4),
                    TextField(
                      controller: problemController,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Descreva o problema',
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('A quanto tempo ocorre?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 4),
                    TextField(
                      controller: timeController,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ex: 15 horas',
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Icon(Icons.image, size: 50, color: Colors.white),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            print('Endereço: ${addressController.text}');
                            print('Problema: ${problemController.text}');
                            print('Tempo: ${timeController.text}');

                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Sucesso'),
                                content: Text(
                                    'Seu relatório foi enviado com sucesso!'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(Icons.touch_app),
                          label: Text('REPORTAR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            addressController.clear();
                            problemController.clear();
                            timeController.clear();
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Homepage()),
                            );
                          },
                          child: Text('CANCELAR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: BorderSide(color: Colors.grey),
                          ),
                        )
                      ],
                    )
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
