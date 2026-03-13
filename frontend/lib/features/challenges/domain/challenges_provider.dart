import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/challenges_service.dart';

class ChallengesState {
  final bool isLoading;
  final List<dynamic> challenges;
  final List<dynamic> achievements;
  final String? error;

  ChallengesState({
    this.isLoading = false,
    this.challenges = const [],
    this.achievements = const [],
    this.error,
  });

  ChallengesState copyWith({
    bool? isLoading,
    List<dynamic>? challenges,
    List<dynamic>? achievements,
    String? error,
  }) {
    return ChallengesState(
      isLoading: isLoading ?? this.isLoading,
      challenges: challenges ?? this.challenges,
      achievements: achievements ?? this.achievements,
      error: error ?? this.error,
    );
  }
}

class ChallengesNotifier extends StateNotifier<ChallengesState> {
  final ChallengesService _challengesService;

  ChallengesNotifier(this._challengesService) : super(ChallengesState());

  Future<void> fetchChallenges() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final challenges = await _challengesService.getChallenges();
      state = state.copyWith(isLoading: false, challenges: challenges);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchAchievements() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final achievements = await _challengesService.getAchievements();
      state = state.copyWith(isLoading: false, achievements: achievements);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> participateInChallenge(String challengeId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _challengesService.participateInChallenge(challengeId);
      await fetchChallenges();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> completeChallenge(String participationId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _challengesService.completeChallenge(participationId);
      await fetchChallenges();
      await fetchAchievements();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}


final challengesProvider = StateNotifierProvider<ChallengesNotifier, ChallengesState>((ref) {
  final challengesService = ref.watch(challengesServiceProvider);
  return ChallengesNotifier(challengesService);
});
