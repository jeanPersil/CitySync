import 'package:flutter/material.dart';
import 'package:citysync/services/feedback.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SuportePage extends StatefulWidget {
  const SuportePage({super.key});

  @override
  State<SuportePage> createState() => _SuportePageState();
}

class _SuportePageState extends State<SuportePage> {
  double _avaliacao = 0.0;
  final TextEditingController _feedbackController = TextEditingController();
  final FeedbackService _feedbackService = FeedbackService();
  bool _isLoading = false;
  final GlobalKey _starRowKey = GlobalKey();

  void _enviarFeedback() async {
    final feedback = _feedbackController.text.trim();

    if (_avaliacao == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, selecione uma avaliação"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, escreva seu feedback"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro: Usuário não autenticado"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final resultado = await _feedbackService.enviarFeedback(
      usuarioId: user.id,
      avaliacao: _avaliacao,
      texto: feedback,
    );

    setState(() {
      _isLoading = false;
    });

    if (resultado == null) {
   
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Obrigado pelo seu feedback!"),
          backgroundColor: Colors.green,
        ),
      );


      setState(() {
        _avaliacao = 0.0;
        _feedbackController.clear();
      });
    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateRatingFromPosition(double localX) {
    final RenderBox? box =
        _starRowKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final width = box.size.width;
    final clampedX = localX.clamp(0.0, width);
    final double rawRating = (clampedX / width) * 10;
    final double rating = (rawRating / 2).clamp(0.0, 5.0);
    
    double finalRating;
    if (rating % 0.5 == 0) {
      finalRating = rating;
    } else {
      finalRating = (rating * 2).round() / 2;
    }
    
    if (finalRating < 0.5 && clampedX > 0) {
      finalRating = 0.5;
    }
    
    setState(() {
      _avaliacao = finalRating.clamp(0.0, 5.0);
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Suporte & Feedback",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black.withOpacity(0.2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E3A5F),
              Color(0xFF152C49),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth > 600 ? screenWidth * 0.2 : 16.0,
                  vertical: 16.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    color: Colors.white.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth > 600 ? 40 : 20,
                        vertical: 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            "Sua opinião é muito importante!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth > 600 ? 24 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          _buildStarRating(),

                          const SizedBox(height: 12),

                          Text(
                            _avaliacao == 0.0
                                ? "Toque ou arraste nas estrelas para avaliar"
                                : "Avaliação: ${_avaliacao.toStringAsFixed(1)} ⭐",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: screenWidth > 600 ? 16 : 14,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          TextField(
                            controller: _feedbackController,
                            maxLines: screenWidth > 600 ? 6 : 5,
                            maxLength: 500,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth > 600 ? 16 : 14,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  "Digite aqui sua sugestão ou problema...",
                              hintStyle:
                                  const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    const BorderSide(color: Colors.white24),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              counterStyle:
                                  const TextStyle(color: Colors.white70),
                            ),
                          ),

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: screenWidth > 600 ? 60 : 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF20C997),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                disabledBackgroundColor: Colors.grey,
                              ),
                              onPressed: _isLoading ? null : _enviarFeedback,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      "Enviar Feedback",
                                      style: TextStyle(
                                        fontSize: screenWidth > 600 ? 20 : 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStarRating() {
    final screenWidth = MediaQuery.of(context).size.width;
    final starSize = screenWidth > 600 ? 48.0 : 40.0;

    return GestureDetector(
      key: _starRowKey,
      onTapDown: (details) {
        _updateRatingFromPosition(details.localPosition.dx);
      },
      onHorizontalDragStart: (details) {
        _updateRatingFromPosition(details.localPosition.dx);
      },
      onHorizontalDragUpdate: (details) {
        _updateRatingFromPosition(details.localPosition.dx);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: _buildStar(index, starSize),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildStar(int index, double size) {
    IconData iconData;
    
    if (_avaliacao >= index + 1) {

      iconData = Icons.star;
    } else if (_avaliacao > index && _avaliacao < index + 1) {
      iconData = Icons.star_half;
    } else {
      iconData = Icons.star_border;
    }

    return Icon(
      iconData,
      color: Colors.amber,
      size: size,
      shadows: const [
        Shadow(
          color: Colors.black26,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    );
  }
}