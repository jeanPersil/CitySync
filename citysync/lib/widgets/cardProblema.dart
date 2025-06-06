import 'package:flutter/material.dart';

class CardPRoblema extends StatelessWidget {
  const CardPRoblema({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), 
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFEDEDED),
          border: Border(
            left: BorderSide(color: Colors.blueAccent, width: 4), 
          ),
          borderRadius:
              BorderRadius.circular(16), 
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vazamento/esgoto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'senai / FSA - 29/08/2003',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                'Em análise',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
