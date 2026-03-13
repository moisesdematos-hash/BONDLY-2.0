import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/garden_service.dart';

class GardenState {
  final bool isLoading;
  final int level;
  final int xp;
  final int health;
  final String? error;

  GardenState({
    this.isLoading = false,
    this.level = 1,
    this.xp = 0,
    this.health = 100,
    this.error,
  });

  GardenState copyWith({
    bool? isLoading,
    int? level,
    int? xp,
    int? health,
    String? error,
  }) {
    return GardenState(
      isLoading: isLoading ?? this.isLoading,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      health: health ?? this.health,
      error: error ?? this.error,
    );
  }
}

class GardenNotifier extends StateNotifier<GardenState> {
  final GardenService _gardenService;

  GardenNotifier(this._gardenService) : super(GardenState());

  Future<void> fetchStats(String relationshipId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final stats = await _gardenService.getGardenStats(relationshipId);
      state = state.copyWith(
        isLoading: false,
        level: stats['level'],
        xp: stats['xp'],
        health: stats['health'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final gardenProvider = StateNotifierProvider<GardenNotifier, GardenState>((ref) {
  final service = ref.watch(gardenServiceProvider);
  return GardenNotifier(service);
});
