import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/nudge_service.dart';

class NudgeState {
  final String? message;
  final String? priority;
  final bool isLoading;

  NudgeState({this.message, this.priority, this.isLoading = false});

  NudgeState copyWith({String? message, String? priority, bool? isLoading}) {
    return NudgeState(
      message: message ?? this.message,
      priority: priority ?? this.priority,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NudgeNotifier extends StateNotifier<NudgeState> {
  final NudgeService _nudgeService;

  NudgeNotifier(this._nudgeService) : super(NudgeState());

  Future<void> fetchNudge(String relationshipId) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _nudgeService.getNudge(relationshipId);
      state = NudgeState(
        message: result['mensagem'],
        priority: result['prioridade'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final nudgeProvider = StateNotifierProvider<NudgeNotifier, NudgeState>((ref) {
  final service = ref.watch(nudgeServiceProvider);
  return NudgeNotifier(service);
});
