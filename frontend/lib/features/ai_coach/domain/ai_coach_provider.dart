import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ai_coach_service.dart';

class AiCoachState {
  final bool isLoading;
  final String? suggestion;
  final String? emotion;
  final String? quickTip;
  final bool? hasConflict;
  final String? error;

  AiCoachState({
    this.isLoading = false,
    this.suggestion,
    this.emotion,
    this.quickTip,
    this.hasConflict,
    this.error,
  });

  AiCoachState copyWith({
    bool? isLoading,
    String? suggestion,
    String? emotion,
    String? quickTip,
    bool? hasConflict,
    String? error,
  }) {
    return AiCoachState(
      isLoading: isLoading ?? this.isLoading,
      suggestion: suggestion ?? this.suggestion,
      emotion: emotion ?? this.emotion,
      quickTip: quickTip ?? this.quickTip,
      hasConflict: hasConflict ?? this.hasConflict,
      error: error ?? this.error,
    );
  }
}


class AiCoachNotifier extends StateNotifier<AiCoachState> {
  final AiCoachService _aiCoachService;

  AiCoachNotifier(this._aiCoachService) : super(AiCoachState());

  Future<void> getSuggestion({
    required String message,
    required String relationshipType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _aiCoachService.getSuggestion(
        message: message,
        relationshipType: relationshipType,
      );
      state = state.copyWith(
        isLoading: false,
        suggestion: result['sugestao'],
        emotion: result['emocao_detectada'],
        quickTip: result['dica_rapida'],
        hasConflict: result['alerta_conflito'],
      );

    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() {
    state = AiCoachState();
  }
}

final aiCoachProvider = StateNotifierProvider<AiCoachNotifier, AiCoachState>((ref) {
  final aiCoachService = ref.watch(aiCoachServiceProvider);
  return AiCoachNotifier(aiCoachService);
});
