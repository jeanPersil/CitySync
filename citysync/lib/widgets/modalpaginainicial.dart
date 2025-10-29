import 'package:citysync/views/report_problema.dart';
import 'package:citysync/widgets/botao_categoria.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

Future<void> mostrarModal(
  BuildContext context, 
  String idUsuario, {
  required LatLng selectedLocation,
  required String selectedAddress,
}) async {
  String? categoriaSelecionada;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  await showModalBottomSheet(
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
                color: isDark ? Colors.grey[900] : const Color(0xFF1E3A5F),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header com informações de localização
                  _buildLocationHeader(selectedAddress, isDark),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Escolha uma das opções que descrevem o seu problema',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Grid de categorias
                  _buildCategoriesGrid(categoriaSelecionada, setModalState),
                  const SizedBox(height: 16),
                  
                  // Botão de continuar
                  _buildContinueButton(
                    context, 
                    categoriaSelecionada, 
                    idUsuario, 
                    selectedLocation, 
                    selectedAddress, 
                    isDark
                  ),
                  const SizedBox(height: 8),
                  
                  // Botão de cancelar
                  _buildCancelButton(context, isDark),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Widget _buildLocationHeader(String address, bool isDark) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isDark ? Colors.grey[800] : const Color(0xFF2A4A7A),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.3),
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Localização selecionada:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          address.length > 60 ? '${address.substring(0, 60)}...' : address,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 11,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

Widget _buildCategoriesGrid(String? categoriaSelecionada, StateSetter setModalState) {
  return Padding(
    padding: const EdgeInsets.all(5.0),
    child: GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.85,
      children: [
        Botaocategoria(
          iconeImagem: Image.asset('assets/images/icones/icone_buraco.png'),
          texto: 'Buraco',
          selecionado: categoriaSelecionada == 'Buraco',
          aoClicar: () {
            setModalState(() {
              categoriaSelecionada = 'Buraco';
            });
          },
        ),
        Botaocategoria(
          iconeImagem: Image.asset('assets/images/icones/icone_poste.png'),
          texto: 'Iluminação',
          selecionado: categoriaSelecionada == 'Iluminação',
          aoClicar: () {
            setModalState(() {
              categoriaSelecionada = 'Iluminação';
            });
          },
        ),
        Botaocategoria(
          iconeImagem: Image.asset('assets/images/icones/icone_lixo.png'),
          texto: 'Lixo',
          selecionado: categoriaSelecionada == 'Lixo',
          aoClicar: () {
            setModalState(() {
              categoriaSelecionada = 'Lixo';
            });
          },
        ),
        Botaocategoria(
          iconeImagem: Image.asset('assets/images/icones/icone_semafaro.png'),
          texto: 'Semafaro',
          selecionado: categoriaSelecionada == 'Semafaro',
          aoClicar: () {
            setModalState(() {
              categoriaSelecionada = 'Semafaro';
            });
          },
        ),
        Botaocategoria(
          iconeImagem: Image.asset('assets/images/icones/icone_vazamento.png'),
          texto: 'Vazamento/esgoto',
          selecionado: categoriaSelecionada == 'Vazamento/esgoto',
          aoClicar: () {
            setModalState(() {
              categoriaSelecionada = 'Vazamento/esgoto';
            });
          },
        ),
        Botaocategoria(
          iconeImagem: Image.asset('assets/images/icones/transporte.png'),
          texto: 'Transporte',
          selecionado: categoriaSelecionada == 'Transporte',
          aoClicar: () {
            setModalState(() {
              categoriaSelecionada = 'Transporte';
            });
          },
        ),
        Botaocategoria(
          iconeImagem: Image.asset('assets/images/icones/outros.png'),
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
  );
}

Widget _buildContinueButton(
  BuildContext context,
  String? categoriaSelecionada,
  String idUsuario,
  LatLng selectedLocation,
  String selectedAddress,
  bool isDark,
) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: categoriaSelecionada == null
          ? null
          : () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TelaReport(
                    categoria: categoriaSelecionada,
                    usuarioId: idUsuario,
                    selectedLocation: selectedLocation,
                    selectedAddress: selectedAddress,
                  ),
                ),
              );
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: categoriaSelecionada == null 
            ? Colors.grey 
            : Colors.redAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 4,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Continuar'),
          if (categoriaSelecionada != null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 18),
          ],
        ],
      ),
    ),
  );
}

Widget _buildCancelButton(BuildContext context, bool isDark) {
  return SizedBox(
    width: double.infinity,
    child: TextButton(
      onPressed: () => Navigator.pop(context),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        'Cancelar',
        style: TextStyle(
          fontSize: 14,
          color: Colors.white70,
        ),
      ),
    ),
  );
}