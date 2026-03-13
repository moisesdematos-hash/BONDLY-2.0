import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/date_provider.dart';
import '../../relationship/domain/relationship_provider.dart';
import '../../../core/theme/bondly_theme.dart';

class DatePlannerScreen extends ConsumerStatefulWidget {
  const DatePlannerScreen({super.key});

  @override
  ConsumerState<DatePlannerScreen> createState() => _DatePlannerScreenState();
}

class _DatePlannerScreenState extends ConsumerState<DatePlannerScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final relationshipId = ref.read(relationshipProvider).selectedRelationship?['id'];
      if (relationshipId != null) {
        ref.read(dateProvider.notifier).fetchSuggestions(relationshipId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dateProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Planejador de Date Nights'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: BondlyTheme.mainGradient),
        child: SafeArea(
          child: state.isLoading
              ? _buildLoadingState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sugestões de Hoje 🥂',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Baseado no clima recente de vocês, a IA selecionou estas experiências:',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 32),
                      if (state.suggestions.isEmpty)
                        const Center(child: Text('Nenhuma sugestão no momento.'))
                      else
                        ...state.suggestions.map((s) => _buildDateCard(s)),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFFFB923C)),
          const SizedBox(height: 24),
          const Text(
            'Bondly IA está criando momentos...',
            style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(dynamic suggestion) {
    final bool isCasa = suggestion['tipo'] == 'casa';
    final bool isPremium = suggestion['premium'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BondlyTheme.glassDecoration(opacity: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCasa ? Colors.blueAccent.withOpacity(0.1) : Colors.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isCasa ? '🏠 EM CASA' : '🚗 RUA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isCasa ? Colors.blueAccent : Colors.greenAccent,
                  ),
                ),
              ),
              if (isPremium)
                const Icon(Icons.star, color: Colors.amber, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            suggestion['titulo'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            suggestion['descricao'],
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_fix_high, size: 18, color: Color(0xFFFB923C)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'POR QUE SUGERIMOS?',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white38),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        suggestion['por_que'],
                        style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
