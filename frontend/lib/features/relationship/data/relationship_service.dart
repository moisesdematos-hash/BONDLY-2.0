import 'dart:convert';
import '../../../core/network/api_client.dart';

class RelationshipService {
  final ApiClient apiClient;

  RelationshipService({required this.apiClient});

  Future<List<Map<String, dynamic>>> getRelationships() async {
    final response = await apiClient.get('/relationships');

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao carregar relacionamentos');
    }
  }

  Future<Map<String, dynamic>> createRelationship(String type, String? name) async {
    final response = await apiClient.post('/relationships', {
      'type': type,
      'name': name,
    });

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Falha ao criar relacionamento');
    }
  }

  Future<Map<String, dynamic>> joinRelationship(String inviteCode) async {
    final response = await apiClient.post('/relationships/join', {
      'inviteCode': inviteCode,
    });

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Falha ao entrar no relacionamento');
    }
  }

  Future<void> deleteRelationship(String id) async {
    final response = await apiClient.delete('/relationships/$id');
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Falha ao excluir relacionamento');
    }
  }
}


