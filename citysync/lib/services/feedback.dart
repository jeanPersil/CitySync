import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackService{
  final supabase = Supabase.instance.client;

  Future<String?> enviarFeedback({
    required String usuarioId,
    required double avaliacao,
    required String texto,
  }) async {
    try {
      if (avaliacao < 0.5 || avaliacao > 5.0) {
        return "Avaliação deve estar entre 0.5 e 5.0";
    }

    if (texto.trim().isEmpty) {
      return "O texto do feedback não pode estar vazio";
    }
    await supabase.from('feedback').insert({
      'fk_usuario': usuarioId,
      'avaliacao': avaliacao,
      'texto': texto,
    });
    return null;
    } catch (e) {
      return "Erro ao enviar feedback: $e";
    }
  }

  Future<List<Map<String, dynamic>>> listarFeedbacksUsuario(
    String usuarioId) async {
  try{
    final response = await supabase
        .from('feedback')
        .select()
        .eq('fk_usuario', usuarioId)
        .order('data_criacao', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  } catch (e) {
    throw Exception("Erro ao listar feedbacks: $e");
    }
  }
}