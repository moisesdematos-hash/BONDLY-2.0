import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class QuestionsService {
  final ApiClient _apiClient;

  QuestionsService(this._apiClient);

  Future<Map<String, dynamic>> getDailyQuestion(String relationshipId, String relationshipType, {String language = 'pt'}) async {
    final response = await _apiClient.get('/questions/daily/$relationshipId?relationshipType=$relationshipType&language=$language');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao buscar pergunta do dia');
    }
  }

  Future<void> submitAnswer({
    required String questionId,
    required String relationshipId,
    required String answer,
  }) async {
    final response = await _apiClient.post(
      '/questions/answer',
      {
        'question_id': questionId,
        'relationship_id': relationshipId,
        'answer_text': answer,
      },
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Falha ao enviar resposta');
    }
  }
}

final questionsServiceProvider = Provider<QuestionsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return QuestionsService(apiClient);
});
