import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/nudge_provider.dart';
import '../../../core/theme/bondly_theme.dart';

class NudgeWidget extends ConsumerWidget {
  const NudgeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nudgeProvider);

    if (state.isLoading || state.message == null) {
      return const SizedBox.shrink();
    }

    final isHigh = state.priority == 'alta';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHigh ? Colors.amber.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHigh ? Colors.amber.withOpacity(0.3) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isHigh ? Icons.priority_high : Icons.lightbulb_outline,
            color: isHigh ? Colors.amber : Colors.white54,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.message!,
              style: TextStyle(
                color: isHigh ? Colors.white : Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
