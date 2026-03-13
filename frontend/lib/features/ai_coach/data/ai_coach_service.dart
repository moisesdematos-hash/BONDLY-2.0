import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class AiCoachService {
  final ApiClient _apiClient;

  AiCoachService(this._apiClient);

  Future<Map<String, dynamic>> getSuggestion({
    required String message,
    required String relationshipType,
    String? language,
  }) async {
    final response = await _apiClient.post(
      '/ai-coach/suggest',
      {
        'message': message,
        'relationshipType': relationshipType,
        'language': language ?? 'pt',
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao obter sugestão do AI Coach');
    }
  }
}

final aiCoachServiceProvider = Provider<AiCoachService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AiCoachService(apiClient);
});
