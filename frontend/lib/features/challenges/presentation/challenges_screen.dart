import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/challenges_provider.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(challengesProvider.notifier).fetchChallenges();
      ref.read(challengesProvider.notifier).fetchAchievements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengesProvider);

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Desafios & Conquistas'),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    const Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(Icons.emoji_events, size: 200, color: Colors.white10),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                const TabBar(
                  tabs: [
                    Tab(text: 'Ativos'),
                    Tab(text: 'Conquistas'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ],
          body: TabBarView(
            children: [
              _ChallengesList(state: state),
              _AchievementsList(state: state),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChallengesList extends ConsumerWidget {
  final ChallengesState state;
  const _ChallengesList({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading && state.challenges.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.challenges.isEmpty) {
      return _EmptyState(
        icon: Icons.star_outline,
        message: 'Nenhum desafio disponível no momento.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: state.challenges.length,
      itemBuilder: (context, index) {
        final challenge = state.challenges[index];
        final participation = challenge['participation'];
        final status = participation?['status'];

        return _ChallengeCard(
          challenge: challenge,
          status: status,
          onAction: () async {
            if (status == null) {
              await ref.read(challengesProvider.notifier).participateInChallenge(challenge['id']);
            } else if (status == 'pending') {
              await ref.read(challengesProvider.notifier).completeChallenge(participation['id']);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Desafio concluído! 🎉')),
                );
              }
            }
          },
        );
      },
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final Map<String, dynamic> challenge;
  final String? status;
  final VoidCallback onAction;

  const _ChallengeCard({
    required this.challenge,
    this.status,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == 'completed';
    final isPending = status == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      color: Colors.white.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusBadge(status: status),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${challenge['points']} pts',
                    style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              challenge['title'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              challenge['description'],
              style: const TextStyle(color: Colors.white60, height: 1.5),
            ),
            const SizedBox(height: 24),
            if (!isCompleted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isPending ? const Color(0xFF6366F1) : Colors.white10,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    isPending ? 'Marcar como Concluído' : 'Aceitar Desafio',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String? status;
  const _StatusBadge({this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    String text = 'Disponível';

    if (status == 'pending') {
      color = Colors.blueAccent;
      text = 'Em Progresso';
    } else if (status == 'completed') {
      color = Colors.greenAccent;
      text = 'Concluído';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _AchievementsList extends StatelessWidget {
  final ChallengesState state;
  const _AchievementsList({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.achievements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.achievements.isEmpty) {
      return _EmptyState(
        icon: Icons.emoji_events_outlined,
        message: 'Você ainda não possui conquistas. Que tal começar um desafio?',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: state.achievements.length,
      itemBuilder: (context, index) {
        final achievement = state.achievements[index];
        return Card(
          elevation: 0,
          color: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emoji_events, size: 40, color: Colors.amber),
              ),
              const SizedBox(height: 16),
              Text(
                _getAchievementName(achievement['type']),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '+${achievement['points']} pts',
                style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getAchievementName(String type) {
    if (type == 'challenge_completed') return 'Desafio Concluído';
    return type;
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.white10),
          const SizedBox(height: 24),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white30, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
