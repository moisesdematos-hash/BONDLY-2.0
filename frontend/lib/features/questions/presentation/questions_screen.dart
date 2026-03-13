import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/questions_provider.dart';
import '../../relationship/domain/relationship_provider.dart';

class QuestionsScreen extends ConsumerStatefulWidget {
  const QuestionsScreen({super.key});

  @override
  ConsumerState<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends ConsumerState<QuestionsScreen> {
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final relationship = ref.read(relationshipProvider).selectedRelationship;
      final relationshipId = relationship?['id'];
      final relationshipType = relationship?['type'] ?? 'casal';
      if (relationshipId != null) {
        ref.read(questionsProvider.notifier).fetchDailyQuestion(relationshipId, relationshipType);
      }
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionsProvider);
    final relationshipState = ref.watch(relationshipProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Conexão Diária'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: state.isLoading && state.currentQuestion == null
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.currentQuestion != null) ...[
                        const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 60),
                        const SizedBox(height: 24),
                        Text(
                          state.currentQuestion!['question_text'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 48),
                        if (!state.isAnswered) ...[
                          _buildAnswerInput(state, relationshipState),
                        ] else ...[
                          _buildRevealState(state),
                        ],
                      ] else if (state.error != null)
                        _buildErrorState(state.error!)
                      else
                        const Center(
                          child: Text(
                            'Nenhuma pergunta para hoje. Volte amanhã! ❤️',
                            style: TextStyle(color: Colors.white70, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildAnswerInput(QuestionsState state, RelationshipState relState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _answerController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Sua resposta honesta...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(24),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: state.isLoading
              ? null
              : () {
                  if (_answerController.text.trim().isNotEmpty) {
                    ref.read(questionsProvider.notifier).submitAnswer(
                          questionId: state.currentQuestion!['id'],
                          relationshipId: relState.selectedRelationship!['id'],
                          relationshipType: relState.selectedRelationship!['type'] ?? 'casal',
                          answer: _answerController.text.trim(),
                        );
                  }
                },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF4F46E5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 8,
          ),
          child: state.isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Enviar de Coração',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }

  Widget _buildRevealState(QuestionsState state) {
    final partnerAnswer = state.currentQuestion!['partner_answer'];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 40),
              const SizedBox(height: 16),
              const Text(
                'Sua resposta foi enviada!',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                state.currentQuestion!['user_answer_text'] ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        if (partnerAnswer == null)
          _buildWaitingPartner()
        else
          _buildPartnerAnswer(partnerAnswer),
      ],
    );
  }

  Widget _buildWaitingPartner() {
    return Column(
      children: [
        const CircularProgressIndicator(color: Colors.white70),
        const SizedBox(height: 24),
        Text(
          'Aguardando a resposta do parceiro...',
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'A resposta será revelada assim que ambos responderem.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPartnerAnswer(String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Text(
            'Revelado! ✨',
            style: TextStyle(color: Colors.amberAccent, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'O que o parceiro disse:',
                style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                answer,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87, fontSize: 20, height: 1.4, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.white70, size: 60),
          const SizedBox(height: 16),
          Text(
            'Ops! Algo deu errado.\n$error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
