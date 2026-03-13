import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/date_service.dart';

class DateState {
  final List<dynamic> suggestions;
  final bool isLoading;
  final String? error;

  DateState({
    this.suggestions = const [],
    this.isLoading = false,
    this.error,
  });

  DateState copyWith({
    List<dynamic>? suggestions,
    bool? isLoading,
    String? error,
  }) {
    return DateState(
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DateNotifier extends StateNotifier<DateState> {
  final DateService _dateService;

  DateNotifier(this._dateService) : super(DateState());

  Future<void> fetchSuggestions(String relationshipId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _dateService.getDateSuggestions(relationshipId);
      state = state.copyWith(
        suggestions: result['sugestoes'],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dateProvider = StateNotifierProvider<DateNotifier, DateState>((ref) {
  final service = ref.watch(dateServiceProvider);
  return DateNotifier(service);
});
