import 'package:flutter/material.dart';

class Botaocategoria extends StatelessWidget {
  final Widget iconeImagem;
  final String texto;

  final Function() aoClicar;
  final bool selecionado;

  const Botaocategoria(
      {super.key,
      required this.iconeImagem,
      required this.texto,
      this.selecionado = false,
      required this.aoClicar});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
            onPressed: () => aoClicar(),
            style: ElevatedButton.styleFrom(
                backgroundColor: selecionado ? Colors.orange : Colors.white),
            child: SizedBox(height: 28, width: 28, child: iconeImagem)),
        Text(
          texto,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}


/*

estureDetector(
      onTap: () => aoClicar(id),
      child: Container(
        decoration: BoxDecoration(
          color: clicado ? Colors.green : Colors.red
        ),
        child: Column(
          children: [
            Icon(icone),
            Text(
              texto,
            )
          ],
        ),
      ),
    );
 */