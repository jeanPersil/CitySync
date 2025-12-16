import 'package:citysync/views/report_problema.dart';
import 'package:flutter/material.dart';

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

final List<Map<String, dynamic>> _categoriasData = [
  {
    'titulo': 'Buraco',
    'cor': const Color(0xFFFF9800),
    'asset': 'assets/images/icones/icone_buraco.png'
  },
  {
    'titulo': 'Iluminação',
    'cor': const Color(0xFFFFC107),
    'asset': 'assets/images/icones/icone_poste.png'
  },
  {
    'titulo': 'Lixo',
    'cor': const Color(0xFF4CAF50),
    'asset': 'assets/images/icones/icone_lixo.png'
  },
  {
    'titulo': 'Semafaro',
    'cor': const Color(0xFFF44336),
    'asset': 'assets/images/icones/icone_semafaro.png'
  },
  {
    'titulo': 'Vazamento/esgoto',
    'cor': const Color(0xFF2196F3),
    'asset': 'assets/images/icones/icone_vazamento.png'
  },
  {
    'titulo': 'Transporte',
    'cor': const Color(0xFF9C27B0),
    'asset': 'assets/images/icones/transporte.png'
  },
  {
    'titulo': 'Outros',
    'cor': const Color(0xFF607D8B),
    'asset': 'assets/images/icones/outros.png'
  },
];


Future<void> mostrarModal(BuildContext context, String idUsuario) async {
  String? categoriaSelecionada;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) {
      return SafeArea(
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              margin: const EdgeInsets.only(top: 60),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Header com ícone e título
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Reportar Problema',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Escolha a categoria do problema',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.grey.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _categoriasData.map((data) {
                        return _buildCategoriaCard(
                          context: context,
                          setModalState: setModalState,
                          categoriaSelecionada: categoriaSelecionada,
                          onSelect: (categoria) {
                            setModalState(() {
                              categoriaSelecionada = categoria;
                            });
                          },
                          icone: Image.asset(data['asset'] as String),
                          titulo: data['titulo'] as String,
                          cor: data['cor'] as Color,
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: categoriaSelecionada == null
                            ? null
                            : () {
                                Navigator.pop(ctx); 
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TelaReport(
                                      categoria: categoriaSelecionada!,
                                      usuarioId: idUsuario,
                                    ),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: categoriaSelecionada == null
                              ? (Colors.grey[300])
                              : const Color.fromARGB(255, 255, 255, 255),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color.fromARGB(136, 224, 224, 224),
                          disabledForegroundColor: Colors.black38,
                          elevation: categoriaSelecionada == null ? 0 : 4,
                          shadowColor: const Color(0xFF1E3A5F).withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Continuar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: Colors.black,
                              ),
                            ),
                            if (categoriaSelecionada != null) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 24),
                            ],
                          ],
                        ),
                      ),
                    ),
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

Widget _buildCategoriaCard({
  required BuildContext context,
  required StateSetter setModalState,
  required String? categoriaSelecionada,
  required Function(String) onSelect,
  required Widget icone,
  required String titulo,
  required Color cor,
}) {
  final bool isSelected = categoriaSelecionada == titulo;

  return GestureDetector(
    onTap: () => onSelect(titulo),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? cor.withValues(alpha: 0.15) : (Colors.grey[100]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? cor : Colors.transparent,
          width: 2.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: cor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? cor.withValues(alpha: 0.2) : (Colors.white),
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 36,
              height: 36,
              child: icone,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              titulo,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? cor : (const Color(0xFF1E3A5F)),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}