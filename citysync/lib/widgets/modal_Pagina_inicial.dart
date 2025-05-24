import 'package:citysync/widgets/botaoCategoria.dart';
import 'package:flutter/material.dart';

void mostrarModal(BuildContext context) {
  String? categoriaSelecionada;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext ctx) {
      return SafeArea(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Escolha uma das opções que descrevem o seu problema',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        Botaocategoria(
                          iconeImagem: Image.asset(
                              'assets/images/icones/icone_buraco.png'),
                          texto: 'Buraco',
                          selecionado: categoriaSelecionada == 'Buraco',
                          aoClicar: () {
                            setModalState(() {
                              categoriaSelecionada = 'Buraco';
                            });
                          },
                        ),
                        Botaocategoria(
                          iconeImagem: Image.asset(
                              'assets/images/icones/icone_poste.png'),
                          texto: 'Iluminação',
                          selecionado: categoriaSelecionada == 'Iluminação',
                          aoClicar: () {
                            setModalState(() {
                              categoriaSelecionada = 'Iluminação';
                            });
                          },
                        ),
                        Botaocategoria(
                          iconeImagem: Image.asset(
                              'assets/images/icones/icone_lixo.png'),
                          texto: 'Lixo',
                          selecionado: categoriaSelecionada == 'Lixo',
                          aoClicar: () {
                            setModalState(() {
                              categoriaSelecionada = 'Lixo';
                            });
                          },
                        ),
                        Botaocategoria(
                          iconeImagem: Image.asset(
                              'assets/images/icones/icone_semafaro.png'),
                          texto: 'Semafaro',
                          selecionado: categoriaSelecionada == 'Semafaro',
                          aoClicar: () {
                            setModalState(() {
                              categoriaSelecionada = 'Semafaro';
                            });
                          },
                        ),
                        Botaocategoria(
                          iconeImagem: Image.asset(
                              'assets/images/icones/icone_vazamento.png'),
                          texto: 'Vazamento/esgoto',
                          selecionado:
                              categoriaSelecionada == 'Vazamento/esgoto',
                          aoClicar: () {
                            setModalState(() {
                              categoriaSelecionada = 'Vazamento/esgoto';
                            });
                          },
                        ),
                        Botaocategoria(
                          iconeImagem: Image.asset(
                              'assets/images/icones/transporte.png'),
                          texto: 'Transporte',
                          selecionado: categoriaSelecionada == 'Transporte',
                          aoClicar: () {
                            setModalState(() {
                              categoriaSelecionada = 'Transporte';
                            });
                          },
                        ),
                        Botaocategoria(
                          iconeImagem:
                              Image.asset('assets/images/icones/outros.png'),
                          texto: 'Outros',
                          selecionado: categoriaSelecionada == 'Outros',
                          aoClicar: () {
                            setModalState(() {
                              categoriaSelecionada = 'Outros';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: categoriaSelecionada == null
                        ? null
                        : () {
                            print(categoriaSelecionada);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.white.withOpacity(0.6),
                      disabledForegroundColor: Colors.black45,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      elevation: 4,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Continuar'),
                  )
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
