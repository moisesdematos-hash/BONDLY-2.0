import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class ChatService {
  final ApiClient _apiClient;

  ChatService(this._apiClient);

  Future<List<dynamic>> getMessages(String relationshipId) async {
    final response = await _apiClient.get('/chat/relationship/$relationshipId');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao buscar mensagens');
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String relationshipId,
    required String content,
  }) async {
    final response = await _apiClient.post(
      '/chat/send',
      {
        'relationshipId': relationshipId,
        'content': content,
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao enviar mensagem');
    }
  }
}

final chatServiceProvider = Provider<ChatService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChatService(apiClient);
});
