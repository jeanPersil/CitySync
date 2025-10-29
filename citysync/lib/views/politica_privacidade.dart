import 'package:flutter/material.dart';

class PoliticaPrivacidadePage extends StatelessWidget {
  const PoliticaPrivacidadePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Política de Privacidade',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDark ? Colors.grey[900]!  : const Color(0xFF1E3A5F),
              isDark ? Colors.grey[900]!  : const Color(0xFF152C49),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.white.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Última atualização: 06 de Junho de 2025',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildParagraph(
                        'Bem-vindo ao CitySync! Sua privacidade é extremamente importante para nós. Esta Política de Privacidade descreve como coletamos, usamos e protegemos suas informações pessoais ao utilizar nosso aplicativo.',
                      ),
                      _buildSectionTitle('1. Informações que Coletamos'),
                      _buildParagraph(
                        'Coletamos informações que você nos fornece diretamente, como nome, CPF, e-mail, telefone, endereço (logradouro, número, bairro, cidade, estado, CEP) ao se cadastrar. Também podemos coletar dados sobre o uso do aplicativo para melhorar nossos serviços, como informações sobre os reportes que você cria.',
                      ),
                      _buildSectionTitle('2. Como Usamos Suas Informações'),
                      _buildParagraph(
                        'Utilizamos suas informações para:\n'
                        '- Gerenciar sua conta e fornecer os serviços do aplicativo.\n'
                        '- Processar seus reportes e direcioná-los às autoridades competentes.\n'
                        '- Melhorar e personalizar sua experiência com o CitySync.\n'
                        '- Enviar comunicações importantes sobre o serviço ou atualizações.\n'
                        '- Cumprir obrigações legais.',
                      ),
                      _buildSectionTitle('3. Compartilhamento de Informações'),
                      _buildParagraph(
                        'Não vendemos suas informações pessoais. Podemos compartilhá-las com autoridades governamentais e parceiros de serviço (apenas o necessário para o funcionamento do CitySync) para processar seus reportes e manter a infraestrutura do aplicativo. Todas as informações são tratadas com a máxima confidencialidade e segurança.',
                      ),
                      _buildSectionTitle('4. Segurança dos Dados'),
                      _buildParagraph(
                        'Empregamos medidas de segurança robustas para proteger suas informações contra acesso não autorizado, alteração, divulgação ou destruição. Embora nos esforcemos para proteger seus dados, nenhum método de transmissão pela internet ou armazenamento eletrônico é 100% seguro.',
                      ),
                      _buildSectionTitle('5. Seus Direitos'),
                      _buildParagraph(
                        'Você tem o direito de acessar, corrigir ou excluir suas informações pessoais. Para exercer esses direitos, entre em contato conosco através dos canais de suporte no aplicativo.',
                      ),
                      _buildSectionTitle('6. Alterações a Esta Política'),
                      _buildParagraph(
                        'Podemos atualizar esta Política de Privacidade periodicamente. Notificaremos você sobre quaisquer alterações significativas através do aplicativo ou por e-mail. O uso continuado do aplicativo após as alterações implica aceitação da nova política.',
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Obrigado por usar o CitySync!',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        height: 1.6,
      ),
      textAlign: TextAlign.justify,
    );
  }
}
