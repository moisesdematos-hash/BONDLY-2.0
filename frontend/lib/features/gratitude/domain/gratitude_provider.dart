import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/gratitude_service.dart';

class GratitudeState {
  final bool isLoading;
  final List<dynamic> entries;
  final String? error;

  GratitudeState({
    this.isLoading = false,
    this.entries = const [],
    this.error,
  });

  GratitudeState copyWith({
    bool? isLoading,
    List<dynamic>? entries,
    String? error,
  }) {
    return GratitudeState(
      isLoading: isLoading ?? this.isLoading,
      entries: entries ?? this.entries,
      error: error ?? this.error,
    );
  }
}

class GratitudeNotifier extends StateNotifier<GratitudeState> {
  final GratitudeService _service;

  GratitudeNotifier(this._service) : state(GratitudeState());

  Future<void> fetchEntries(String relationshipId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final entries = await _service.getGratitudeEntries(relationshipId);
      state = state.copyWith(isLoading: false, entries: entries);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> uploadAudio(String relationshipId, String filePath) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.uploadGratitudeAudio(relationshipId, filePath);
      await fetchEntries(relationshipId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteEntry(String id, String relationshipId) async {
    try {
      await _service.deleteEntry(id);
      await fetchEntries(relationshipId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final gratitudeProvider = StateNotifierProvider<GratitudeNotifier, GratitudeState>((ref) {
  final service = ref.watch(gratitudeServiceProvider);
  return GratitudeNotifier(service);
});
