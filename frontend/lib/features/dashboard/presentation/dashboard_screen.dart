import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/auth_provider.dart';
import '../../relationship/domain/relationship_provider.dart';
import '../../challenges/domain/challenges_provider.dart';
import '../../questions/domain/questions_provider.dart';
import '../../checkin/domain/checkins_provider.dart';
import '../../memory_wall/domain/memory_provider.dart';
import '../../garden/domain/garden_provider.dart';
import '../../garden/presentation/garden_widget.dart';
import '../../nudges/domain/nudge_provider.dart';
import '../../nudges/presentation/nudge_widget.dart';
import '../../../core/theme/bondly_theme.dart';



class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final relationshipId = ref.read(relationshipProvider).selectedRelationship?['id'];
      if (relationshipId != null) {
        ref.read(challengesProvider.notifier).fetchChallenges(relationshipId);
        ref.read(questionsProvider.notifier).fetchDailyQuestion(relationshipId);
        ref.read(checkinsProvider.notifier).fetchPartnerStatus(relationshipId);
        ref.read(gardenProvider.notifier).fetchStats(relationshipId);
        ref.read(nudgeProvider.notifier).fetchNudge(relationshipId);
      }


    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final relationshipState = ref.watch(relationshipProvider);
    final challengesState = ref.watch(challengesProvider);
    final questionsState = ref.watch(questionsProvider);
    final checkinsState = ref.watch(checkinsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Olá, ${authState.user?['name']?.split(' ')[0] ?? "Bondly"}! ✨',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: BondlyTheme.mainGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GardenWidget(),
                const SizedBox(height: 16),
                const NudgeWidget(),
                const SizedBox(height: 16),
                _buildDynamicStatus(questionsState, checkinsState),


                const SizedBox(height: 32),
                _buildSectionLabel('Ações Rápidas'),
                const SizedBox(height: 16),
                _buildActionGrid(context),
                const SizedBox(height: 40),
                _buildSectionLabel('Desafios da Semana'),
                const SizedBox(height: 16),
                _buildChallengeSection(challengesState),
                const SizedBox(height: 40),
                _buildAICoachTeaser(context),
                const SizedBox(height: 20),
                _buildDatePlannerTeaser(context),
                const SizedBox(height: 48),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withOpacity(0.4),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDynamicStatus(QuestionsState qState, CheckinsState cState) {
    final bool questionDone = qState.dailyQuestion?['my_answer'] != null;
    final bool checkinDone = cState.history.any((c) {
      final date = DateTime.parse(c['created_at']);
      return date.day == DateTime.now().day && date.month == DateTime.now().month;
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BondlyTheme.glassDecoration(opacity: 0.08),
      child: Row(
        children: [
          _StatusIndicator(
            label: 'Questão',
            isDone: questionDone,
            icon: Icons.auto_awesome,
          ),
          Container(width: 1, height: 40, color: Colors.white10),
          _StatusIndicator(
            label: 'Check-in',
            isDone: checkinDone,
            icon: Icons.heart_broken, // mood heart
          ),
          Container(width: 1, height: 40, color: Colors.white10),
          _StatusIndicator(
            label: 'Parceiro',
            isDone: cState.partnerCheckedInToday,
            icon: Icons.people,
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildActionCard(
          context,
          title: 'Chat',
          icon: Icons.chat_bubble_outline_rounded,
          color: const Color(0xFF6366F1),
          route: '/chat',
        ),
        _buildActionCard(
          context,
          title: 'Ensaio',
          icon: Icons.psychology_outlined,
          color: const Color(0xFF2DD4BF),
          route: '/simulation',
        ),
        _buildActionCard(
          context,
          title: 'Perguntas',
          icon: Icons.question_answer_outlined,
          color: const Color(0xFFFB923C),
          route: '/questions',
        ),
        _buildActionCard(
          context,
          title: 'Check-in',
          icon: Icons.mood_outlined,
          color: const Color(0xFFF472B6),
          route: '/checkin',
        ),
        _buildActionCard(
          context,
          title: 'Check-in',
          icon: Icons.mood_outlined,
          color: const Color(0xFFF472B6),
          route: '/checkin',
        ),
        _buildActionCard(
          context,
          title: 'Mural',
          icon: Icons.photo_library_outlined,
          color: const Color(0xFF6366F1),
          route: '/memory-wall',
        ),
        _buildActionCard(
          context,
          title: 'Wishlist',
          icon: Icons.card_giftcard,
          color: const Color(0xFFEAB308),
          route: '/wishlist',
        ),
        _buildActionCard(
          context,
          title: 'Acordos',
          icon: Icons.handshake_outlined,
          color: const Color(0xFF14B8A6),
          route: '/agreements',
        ),
        _buildActionCard(
          context,
          title: 'Gratidão',
          icon: Icons.mic_none_rounded,
          color: const Color(0xFFF472B6),
          route: '/gratitude',
        ),
      ],
    );

  }

  Widget _buildActionCard(BuildContext context, {required String title, required IconData icon, required Color color, required String route}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BondlyTheme.glassDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeSection(ChallengesState state) {
    if (state.isLoading) return const Center(child: CircularProgressIndicator());
    if (state.challenges.isEmpty) return const Text('Nenhum desafio ativo.');

    final challenge = state.challenges.first;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/challenges'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BondlyTheme.glassDecoration(opacity: 0.1),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.emoji_events_outlined, color: Colors.amber),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(challenge['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(challenge['description'], style: const TextStyle(color: Colors.white38, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildAICoachTeaser(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/ai-coach'),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Precisa de um conselho?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                  SizedBox(height: 8),
                  Text('Bondly AI Coach está pronto para te ajudar com sabedoria e empatia.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            SizedBox(width: 16),
            Icon(Icons.auto_fix_high, color: Colors.white, size: 32),
          ],
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String label;
  final bool isDone;
  final IconData icon;

  const _StatusIndicator({required this.label, required this.isDone, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(isDone ? Icons.check_circle : icon, color: isDone ? const Color(0xFF2DD4BF) : Colors.white24, size: 24),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: isDone ? Colors.white : Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}
