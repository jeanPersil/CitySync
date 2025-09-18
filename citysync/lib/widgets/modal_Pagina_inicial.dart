import 'package:citysync/views/report_problema.dart';
import 'package:citysync/widgets/botao_categoria.dart';
import 'package:flutter/material.dart';
import 'package:citysync/Tema/color_extension.dart';

int mapearCategoriaId(String nome) {
  switch (nome.toLowerCase()) {
    case 'buraco':
      return 1;
    case 'iluminação':
      return 2;
    case 'lixo':
      return 3;
    case 'semafaro':
      return 4;
    case 'vazamento/esgoto':
      return 5;
    case 'transporte':
      return 6;
    case 'outros':
      return 7;
    default:
      return 0;
  }
}

void mostrarModal(BuildContext context, String id_usuario) {
  String? categoriaSelecionada;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
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
                color: isDark ? Colors.grey[900] : Color(0xFF1E3A5F),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Escolha uma das opções que descrevem o seu problema',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.white,
                      fontSize: 13,
                    ),
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
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TelaReport(
                                        categoria: categoriaSelecionada!,
                                        usuarioId: id_usuario,
                                      )),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : Colors.white,
                      foregroundColor: isDark ? Colors.black : Colors.black,
                      disabledBackgroundColor: isDark
                          ? Colors.white.withOpacidade(0.4)
                          : Colors.white.withOpacidade(0.6),
                      disabledForegroundColor:
                          isDark ? Colors.black38 : Colors.black45,
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
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
