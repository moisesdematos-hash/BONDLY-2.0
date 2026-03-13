import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class MemoryService {
  final ApiClient _apiClient;

  MemoryService(this._apiClient);

  Future<List<dynamic>> getMemories(String relationshipId) async {
    final response = await _apiClient.get('/memories/$relationshipId');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar memórias');
    }
  }

  Future<Map<String, dynamic>> createMemory(String relationshipId, String imageUrl, String? caption) async {
    final response = await _apiClient.post('/memories', {
      'relationship_id': relationshipId,
      'image_url': imageUrl,
      'caption': caption,
    });
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao salvar memória');
    }
  }

  Future<void> deleteMemory(String id) async {
    final response = await _apiClient.delete('/memories/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao excluir memória');
    }
  }
}

final memoryServiceProvider = Provider<MemoryService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MemoryService(apiClient);
});
