import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/simulation_service.dart';

class SimulationState {
  final bool isLoading;
  final List<dynamic> history;
  final Map<String, dynamic>? lastSimulation;
  final String? error;

  SimulationState({
    this.isLoading = false,
    this.history = const [],
    this.lastSimulation,
    this.error,
  });

  SimulationState copyWith({
    bool? isLoading,
    List<dynamic>? history,
    Map<String, dynamic>? lastSimulation,
    String? error,
  }) {
    return SimulationState(
      isLoading: isLoading ?? this.isLoading,
      history: history ?? this.history,
      lastSimulation: lastSimulation ?? this.lastSimulation,
      error: error ?? this.error,
    );
  }
}

class SimulationNotifier extends StateNotifier<SimulationState> {
  final SimulationService _simulationService;

  SimulationNotifier(this._simulationService) : super(SimulationState());

  Future<void> fetchHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final history = await _simulationService.getSimulations();
      state = state.copyWith(isLoading: false, history: history);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> simulateMessage({
    required String message,
    required String relationshipType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _simulationService.simulateMessage(
        message: message,
        relationshipType: relationshipType,
      );
      state = state.copyWith(
        isLoading: false,
        lastSimulation: result,
      );
      await fetchHistory();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearLastSimulation() {
    state = state.copyWith(lastSimulation: null);
  }
}

final simulationProvider = StateNotifierProvider<SimulationNotifier, SimulationState>((ref) {
  final simulationService = ref.watch(simulationServiceProvider);
  return SimulationNotifier(simulationService);
});
