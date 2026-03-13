import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/garden_provider.dart';
import '../../../core/theme/bondly_theme.dart';

class GardenWidget extends ConsumerWidget {
  const GardenWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gardenProvider);

    if (state.isLoading && state.xp == 0) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BondlyTheme.glassDecoration(opacity: 0.1),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jardim da Conexão',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Nível ${state.level}',
                    style: const TextStyle(color: Color(0xFF2DD4BF), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              _buildHealthIndicator(state.health),
            ],
          ),
          const SizedBox(height: 24),
          _buildGardenVisual(state.level, state.health),
          const SizedBox(height: 24),
          _buildXpBar(state.xp, state.level * 100),
        ],
      ),
    );
  }

  Widget _buildHealthIndicator(int health) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getHealthColor(health).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getHealthColor(health).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.favorite, size: 14, color: _getHealthColor(health)),
          const SizedBox(width: 6),
          Text(
            '$health%',
            style: TextStyle(
              color: _getHealthColor(health),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGardenVisual(int level, int health) {
    // Em um app real, usaríamos Lottie ou Rive para animações complexas
    // Aqui usaremos ícones e cores dinâmicas para simular os estados
    IconData icon = Icons.seedling;
    Color color = Colors.greenAccent;
    double size = 64;

    if (health < 40) {
      icon = Icons.eco_outlined;
      color = Colors.brown[300]!;
    } else if (level < 3) {
      icon = Icons.eco;
      color = Colors.greenAccent;
    } else if (level < 7) {
      icon = Icons.local_florist;
      color = Colors.pinkAccent;
      size = 72;
    } else {
      icon = Icons.auto_awesome;
      color = Colors.amberAccent;
      size = 80;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOutSine,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(icon, size: size, color: color),
          ),
        );
      },
      onEnd: () {}, // Loop could be implemented here
    );
  }

  Widget _buildXpBar(int xp, int max) {
    final double progress = (xp / max).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Experiência', style: TextStyle(color: Colors.white38, fontSize: 12)),
            Text('$xp / $max XP', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            color: const Color(0xFF6366F1),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Color _getHealthColor(int health) {
    if (health > 70) return const Color(0xFF2DD4BF);
    if (health > 30) return Colors.amberAccent;
    return Colors.redAccent;
  }
}
