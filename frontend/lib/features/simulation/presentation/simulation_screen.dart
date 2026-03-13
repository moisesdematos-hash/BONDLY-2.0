import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/simulation_provider.dart';
import '../../relationship/domain/relationship_provider.dart';

class SimulationScreen extends ConsumerStatefulWidget {
  const SimulationScreen({super.key});

  @override
  ConsumerState<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends ConsumerState<SimulationScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(simulationProvider.notifier).fetchHistory();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(simulationProvider);
    final relationshipState = ref.watch(relationshipProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Simulador de Diálogo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SimulationHeader(),
                const SizedBox(height: 32),
                _buildInputSection(state, relationshipState),
                const SizedBox(height: 40),
                if (state.lastSimulation != null) _SimulationResultView(result: state.lastSimulation!),
                const SizedBox(height: 48),
                if (state.history.isNotEmpty) _SimulationHistory(history: state.history),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection(SimulationState state, RelationshipState relState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'O que você pretende dizer?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _messageController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Ex: "Acho que você não está me dando atenção..."',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: Colors.black.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: state.isLoading
                ? null
                : () {
                    if (_messageController.text.trim().isNotEmpty) {
                      ref.read(simulationProvider.notifier).simulateMessage(
                            message: _messageController.text.trim(),
                            relationshipType: relState.selectedRelationship?['type'] ?? 'casal',
                          );
                      FocusScope.of(context).unfocus();
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: const Color(0xFF2DD4BF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            child: state.isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Iniciar Ensaio 🎭', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SimulationHeader extends StatelessWidget {
  const _SimulationHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ensaie sua Conversa',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 12),
        Text(
          'Simule como seu parceiro pode reagir. A IA fará o papel dele(a) e te ajudará a ajustar as palavras para uma conexão melhor.',
          style: TextStyle(color: Colors.white60, fontSize: 16, height: 1.4),
        ),
      ],
    );
  }
}

class _SimulationResultView extends StatelessWidget {
  final Map<String, dynamic> result;

  const _SimulationResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Resultado do Ensaio',
            style: TextStyle(color: Color(0xFF2DD4BF), fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const SizedBox(height: 24),
        
        // Partner Reaction Bubble
        _buildSectionTitle('Reação Simulada do Parceiro:'),
        const SizedBox(height: 12),
        _PartnerBubble(text: result['reacao_parceiro'] ?? '...'),
        
        const SizedBox(height: 32),
        
        // Coaching Feedback
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology, color: Color(0xFF818CF8)),
                  const SizedBox(width: 12),
                  Text(
                    'Tom: ${result['tom_detectado'] ?? 'Observado'}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Análise de Impacto:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
              const SizedBox(height: 8),
              Text(
                result['analise_impacto'] ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 24),
              const Text('Sugestão do Coach:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigoAccent)),
              const SizedBox(height: 8),
              Text(
                result['sugestao_coach'] ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
              ),
            ],
          ),
        ),
        
        if (result['conselho_rapido'] != null) ...[
          const SizedBox(height: 24),
          _QuickConselho(text: result['conselho_rapido']),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
    );
  }
}

class _PartnerBubble extends StatelessWidget {
  final String text;
  const _PartnerBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: const BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Text(
          '"$text"',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}

class _QuickConselho extends StatelessWidget {
  final String text;
  const _QuickConselho({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.flash_on, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimulationHistory extends StatelessWidget {
  final List<dynamic> history;
  const _SimulationHistory({required this.history});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Simulações Anteriores',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final sim = history[index];
            return Card(
              color: Colors.white.withOpacity(0.02),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: Text(sim['simulated_message'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
                subtitle: Text(sim['created_at'].toString().substring(0, 10), style: const TextStyle(color: Colors.white38)),
                trailing: const Icon(Icons.history, color: Colors.white24),
                onTap: () {
                  // Re-show this simulation
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
