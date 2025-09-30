import 'package:citysync/services/validator.dart';

Future<void> testarValidar() async {
  final validar = Validator();

  // 2. Use 'await' para esperar a conclusão do Future<bool>
  final isValid = await validar.validarCEP("44008090");

  if (isValid) {
    print("✅ CEP válido");
  } else {
    print("❌ CEP inválido");
  }
}

void main() {
  testarValidar();
}
