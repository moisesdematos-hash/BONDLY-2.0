import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/checkins_service.dart';

class CheckinsState {
  final bool isLoading;
  final List<dynamic> history;
  final bool partnerCheckedInToday;
  final String? error;

  CheckinsState({
    this.isLoading = false,
    this.history = const [],
    this.partnerCheckedInToday = false,
    this.error,
  });

  CheckinsState copyWith({
    bool? isLoading,
    List<dynamic>? history,
    bool? partnerCheckedInToday,
    String? error,
  }) {
    return CheckinsState(
      isLoading: isLoading ?? this.isLoading,
      history: history ?? this.history,
      partnerCheckedInToday: partnerCheckedInToday ?? this.partnerCheckedInToday,
      error: error ?? this.error,
    );
  }
}

class CheckinsNotifier extends StateNotifier<CheckinsState> {
  final CheckinsService _checkinsService;

  CheckinsNotifier(this._checkinsService) : super(CheckinsState());

  Future<void> fetchHistory(String relationshipId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final history = await _checkinsService.getHistory(relationshipId);
      state = state.copyWith(isLoading: false, history: history);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchPartnerStatus(String relationshipId) async {
    try {
      final status = await _checkinsService.getPartnerStatus(relationshipId);
      state = state.copyWith(partnerCheckedInToday: status);
    } catch (e) {
      // Non-critical error
    }
  }

  Future<void> saveCheckin({
    required String relationshipId,
    required int mood,
    String? note,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _checkinsService.saveCheckin(
        relationshipId: relationshipId,
        mood: mood,
        note: note,
      );
      state = state.copyWith(isLoading: false);
      await fetchHistory(relationshipId);
      await fetchPartnerStatus(relationshipId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Map<String, dynamic>> fetchInsights(String relationshipId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final insights = await _checkinsService.getInsightsFromAI(relationshipId);
      state = state.copyWith(isLoading: false);
      return insights;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final checkinsProvider = StateNotifierProvider<CheckinsNotifier, CheckinsState>((ref) {
  final checkinsService = ref.watch(checkinsServiceProvider);
  return CheckinsNotifier(checkinsService);
});
