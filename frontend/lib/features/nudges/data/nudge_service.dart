import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class NudgeService {
  final ApiClient _apiClient;

  NudgeService(this._apiClient);

  Future<Map<String, dynamic>> getNudge(String relationshipId) async {
    final response = await _apiClient.get('/nudges?relationshipId=$relationshipId&lang=pt');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao obter nudge');
    }
  }
}

final nudgeServiceProvider = Provider<NudgeService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NudgeService(apiClient);
});
