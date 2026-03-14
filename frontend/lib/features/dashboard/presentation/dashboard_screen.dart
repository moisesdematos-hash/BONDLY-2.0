import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/auth_provider.dart';
import '../../relationship/domain/relationship_provider.dart';
import '../../challenges/domain/challenges_provider.dart';
import '../../questions/domain/questions_provider.dart';
import '../../checkin/domain/checkins_provider.dart';
import '../../garden/domain/garden_provider.dart';
import '../../garden/presentation/garden_widget.dart';
import '../../nudges/domain/nudge_provider.dart';
import '../../nudges/presentation/nudge_widget.dart';
import '../../../core/theme/bondly_theme.dart';
import '../../../core/widgets/bondly_widgets.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
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
    final questionsState = ref.watch(questionsProvider);
    final checkinsState = ref.watch(checkinsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Olá, ${authState.user?['name']?.split(' ')[0] ?? "Bondly"}! ✨',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          _buildProfileButton(context),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: BondlyTheme.mainGradient),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => _refreshData(),
            color: BondlyTheme.accent,
            backgroundColor: BondlyTheme.surface,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Hero(tag: 'garden-view', child: GardenWidget()),
                  const SizedBox(height: 16),
                  const NudgeWidget(),
                  const SizedBox(height: 24),
                  _buildDynamicStatus(questionsState, checkinsState),
                  const SizedBox(height: 40),
                  _buildSectionHeader('Menu de Conexão'),
                  const SizedBox(height: 16),
                  _buildActionGrid(context),
                  const SizedBox(height: 48),
                  _buildSectionHeader('O Vosso Próximo Passo'),
                  const SizedBox(height: 16),
                  _buildChallengeSection(),
                  const SizedBox(height: 24),
                  _buildPremiumExperience(context),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BondlyTheme.glassDecoration(opacity: 0.1, borderRadius: 100),
      child: IconButton(
        icon: const Icon(Icons.person_outline, color: Colors.white),
        onPressed: () => Navigator.pushNamed(context, '/profile'),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: BondlyTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicStatus(QuestionsState qState, CheckinsState cState) {
    final bool questionDone = qState.dailyQuestion?['my_answer'] != null;
    final bool checkinDone = cState.history.any((c) {
      final date = DateTime.parse(c['created_at']);
      return date.day == DateTime.now().day && date.month == DateTime.now().month;
    });

    return BondlyCard(
      padding: 16,
      child: Row(
        children: [
          _StatusItem(label: 'Questão', isDone: questionDone, icon: Icons.auto_awesome_outlined),
          _VerticalDivider(),
          _StatusItem(label: 'Mood', isDone: checkinDone, icon: Icons.favorite_border),
          _VerticalDivider(),
          _StatusItem(label: 'Parceiro', isDone: cState.partnerCheckedInToday, icon: Icons.people_outline),
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
      childAspectRatio: 1.15,
      children: [
        _ActionCard(
          title: 'Chat',
          icon: Icons.chat_bubble_outline_rounded,
          color: const Color(0xFF6366F1),
          route: '/chat',
        ),
        _ActionCard(
          title: 'Ensaio',
          icon: Icons.psychology_outlined,
          color: const Color(0xFF2DD4BF),
          route: '/simulation',
        ),
        _ActionCard(
          title: 'Perguntas',
          icon: Icons.question_answer_outlined,
          color: const Color(0xFFFB923C),
          route: '/questions',
        ),
        _ActionCard(
          title: 'Mural',
          icon: Icons.photo_library_outlined,
          color: const Color(0xFFA855F7),
          route: '/memory-wall',
        ),
        _ActionCard(
          title: 'Acordos',
          icon: Icons.handshake_outlined,
          color: const Color(0xFF14B8A6),
          route: '/agreements',
        ),
        _ActionCard(
          title: 'Gratidão',
          icon: Icons.mic_none_rounded,
          color: const Color(0xFFF472B6),
          route: '/gratitude',
        ),
      ],
    );
  }

  Widget _buildChallengeSection() {
    final state = ref.watch(challengesProvider);
    if (state.isLoading) return const BondlyCard(child: Center(child: CircularProgressIndicator()));
    if (state.challenges.isEmpty) return const SizedBox.shrink();

    final challenge = state.challenges.first;
    return BondlyCard(
      onTap: () => Navigator.pushNamed(context, '/challenges'),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFACC15).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars_rounded, color: Color(0xFFFACC15), size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  challenge['description'], 
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
        ],
      ),
    );
  }

  Widget _buildPremiumExperience(BuildContext context) {
    return Column(
      children: [
        _PremiumTeaserCard(
          title: 'Bondly AI Coach',
          subtitle: 'Conselhos personalizados para o vosso momento.',
          icon: Icons.auto_fix_high_rounded,
          gradient: const [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          onTap: () => Navigator.pushNamed(context, '/ai-coach'),
        ),
        const SizedBox(height: 16),
        _PremiumTeaserCard(
          title: 'Date Planner',
          subtitle: 'Deixem a IA planear o vosso próximo encontro.',
          icon: Icons.celebration_rounded,
          gradient: const [Color(0xFF0F172A), Color(0xFF1E293B)],
          onTap: () => Navigator.pushNamed(context, '/dates'),
        ),
      ],
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final bool isDone;
  final IconData icon;

  const _StatusItem({required this.label, required this.isDone, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : icon, 
            color: isDone ? BondlyTheme.secondary : Colors.white24, 
            size: 26,
          ),
          const SizedBox(height: 6),
          Text(
            label, 
            style: TextStyle(
              color: isDone ? Colors.white : Colors.white38, 
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: Colors.white.withOpacity(0.05));
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  const _ActionCard({required this.title, required this.icon, required this.color, required this.route});

  @override
  Widget build(BuildContext context) {
    return BondlyCard(
      padding: 0,
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            title, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _PremiumTeaserCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _PremiumTeaserCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(colors: gradient),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle, 
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(icon, color: Colors.white, size: 32),
          ],
        ),
      ),
    );
  }
}

