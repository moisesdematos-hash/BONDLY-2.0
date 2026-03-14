import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/network/api_client.dart';
import '../../relationship/domain/relationship_provider.dart';
import '../../checkin/domain/checkins_provider.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  bool _isLoading = false;

  Future<void> _handleUpgrade() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await ApiClient.post('/payments/create-checkout', {});
      final url = response['url'] as String?;
      
      if (url != null && await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível abrir o link de pagamento.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao iniciar checkout: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Bondly Premium'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 80),
            const SizedBox(height: 24),
            const Text(
              'Desbloqueie o Potencial Máximo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Acesso ilimitado às ferramentas de IA para fortalecer seu relacionamento.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 16),
            ),
            const SizedBox(height: 48),
            _buildBenefitItem(
              icon: Icons.psychology,
              title: 'Coach de IA Avançado',
              description: 'Conselhos profundos e personalizados para qualquer situação.',
            ),
            _buildBenefitItem(
              icon: Icons.favorite,
              title: 'Sugestões de Encontros',
              description: 'Ideias criativas e exclusivas baseadas no seu perfil.',
            ),
            _buildBenefitItem(
              icon: Icons.trending_up,
              title: 'Análise de Sentimento',
              description: 'Entenda a saúde emocional do seu casal em tempo real.',
            ),
            const SizedBox(height: 64),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleUpgrade,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectanglePlatform.adaptive(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text(
                      'ASSINAR POR R$ 29,90/MÊS',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cancele a qualquer momento.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 64),
            _buildInsightsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection(BuildContext context) {
    // Verificação provisória para simular que um premium user tem acesso ao insight
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Relatório de Relacionamento (AI)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber),
        ),
        const SizedBox(height: 16),
        const Text(
          'A IA analisa os últimos 30 dias de Check-ins para encontrar padrões.',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => _generateInsights(context),
          icon: const Icon(Icons.auto_awesome, color: Colors.amber),
          label: const Text('Gerar Insights Mensais', style: TextStyle(color: Colors.amber)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: Colors.amber),
          ),
        ),
      ],
    );
  }

  Future<void> _generateInsights(BuildContext context) async {
    
    final relationshipId = ref.read(relationshipProvider).selectedRelationship?['id'];
    if (relationshipId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await ref.read(checkinsProvider.notifier).fetchInsights(relationshipId);
      if (mounted) {
        Navigator.pop(context); // close loader
        _showInsightsDialog(context, result['insightsReport'] ?? result['message']);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar insights: $e')),
        );
      }
    }
  }

  void _showInsightsDialog(BuildContext context, String insightsText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Row(
          children: [
            Icon(Icons.psychology, color: Colors.amber),
            SizedBox(width: 8),
            Text('Relatório do AI Coach', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            insightsText,
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.amber, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
