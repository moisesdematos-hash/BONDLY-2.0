import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class ChallengesService {
  final ApiClient _apiClient;

  ChallengesService(this._apiClient);

  Future<List<dynamic>> getChallenges() async {
    final response = await _apiClient.get('/challenges');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao buscar desafios');
    }
  }

  Future<void> participateInChallenge(String challengeId) async {
    final response = await _apiClient.post('/challenges/$challengeId/participate', {});
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Falha ao participar do desafio');
    }
  }

  Future<void> completeChallenge(String participationId) async {
    final response = await _apiClient.put('/challenges/participation/$participationId/complete', {});
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Falha ao completar desafio');
    }
  }

  Future<List<dynamic>> getAchievements() async {
    final response = await _apiClient.get('/challenges/achievements');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao buscar conquistas');
    }
  }
}

final challengesServiceProvider = Provider<ChallengesService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChallengesService(apiClient);
});
