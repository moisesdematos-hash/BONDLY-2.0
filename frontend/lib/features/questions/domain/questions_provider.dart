import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/questions_service.dart';

class QuestionsState {
  final bool isLoading;
  final Map<String, dynamic>? currentQuestion;
  final bool isAnswered;
  final String? error;

  QuestionsState({
    this.isLoading = false,
    this.currentQuestion,
    this.isAnswered = false,
    this.error,
  });

  QuestionsState copyWith({
    bool? isLoading,
    Map<String, dynamic>? currentQuestion,
    bool? isAnswered,
    String? error,
  }) {
    return QuestionsState(
      isLoading: isLoading ?? this.isLoading,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      isAnswered: isAnswered ?? this.isAnswered,
      error: error ?? this.error,
    );
  }
}

class QuestionsNotifier extends StateNotifier<QuestionsState> {
  final QuestionsService _questionsService;

  QuestionsNotifier(this._questionsService) : super(QuestionsState());

  Future<void> fetchDailyQuestion(String relationshipId, String relationshipType) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final question = await _questionsService.getDailyQuestion(relationshipId, relationshipType);
      state = state.copyWith(
        isLoading: false,
        currentQuestion: question,
        isAnswered: question['user_answered'] ?? false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> submitAnswer({
    required String questionId,
    required String relationshipId,
    required String relationshipType,
    required String answer,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _questionsService.submitAnswer(
        questionId: questionId,
        relationshipId: relationshipId,
        answer: answer,
      );
      // Wait a moment for celebration effect then refresh
      state = state.copyWith(isLoading: false, isAnswered: true);
      await fetchDailyQuestion(relationshipId, relationshipType);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}


final questionsProvider = StateNotifierProvider<QuestionsNotifier, QuestionsState>((ref) {
  final questionsService = ref.watch(questionsServiceProvider);
  return QuestionsNotifier(questionsService);
});
