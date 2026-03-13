import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/ai_coach_provider.dart';
import '../../relationship/domain/relationship_provider.dart';

class AiCoachScreen extends ConsumerStatefulWidget {
  const AiCoachScreen({super.key});

  @override
  ConsumerState<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends ConsumerState<AiCoachScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiCoachProvider);
    final relationshipState = ref.watch(relationshipProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bondly AI Coach'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _CoachHeader(),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              maxLines: 5,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Ex: Meu parceiro disse que está cansado e eu não sei o que responder...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: aiState.isLoading
                  ? null
                  : () {
                      if (_controller.text.trim().isNotEmpty) {
                        ref.read(aiCoachProvider.notifier).getSuggestion(
                              message: _controller.text.trim(),
                              relationshipType: relationshipState.selectedRelationship?['type'] ?? 'casal',
                            );
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: aiState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Analisar com IA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),
            if (aiState.suggestion != null) _AiSuggestionCard(state: aiState),
            if (aiState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  aiState.error!,
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CoachHeader extends StatelessWidget {
  const _CoachHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'O que está acontecendo?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Descreva a situação ou cole uma mensagem. Eu te ajudarei a entender os sentimentos envolvidos e a encontrar a melhor forma de se conectar.',
          style: TextStyle(color: Colors.white60, fontSize: 15, height: 1.4),
        ),
      ],
    );
  }
}

class _AiSuggestionCard extends StatelessWidget {
  final AiCoachState state;

  const _AiSuggestionCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.15),
            Colors.purple.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined, color: Color(0xFF818CF8), size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Análise da IA', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  Text(
                    'Tom Detectado: ${state.emotion ?? "Observador"}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const Spacer(),
              if (state.hasConflict == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                  ),
                  child: const Text('Risco de Conflito', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Sugestão do Coach:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigoAccent),
          ),
          const SizedBox(height: 12),
          Text(
            state.suggestion!,
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
          if (state.quickTip != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.quickTip!,
                      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
