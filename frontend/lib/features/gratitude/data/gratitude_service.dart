import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class GratitudeService {
  final ApiClient _apiClient;

  GratitudeService(this._apiClient);

  Future<List<dynamic>> getGratitudeEntries(String relationshipId) async {
    final response = await _apiClient.get('/gratitude/relationship/$relationshipId');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao carregar o diário de gratidão');
    }
  }

  Future<void> uploadGratitudeAudio(String relationshipId, String filePath) async {
    // We need to use a multipart request for the file upload
    final uri = Uri.parse('${_apiClient.baseUrl}/gratitude/upload');
    final request = http.MultipartRequest('POST', uri);
    
    // Add auth header
    final token = _apiClient.token;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['relationship_id'] = relationshipId;
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Falha ao enviar áudio: ${response.body}');
    }
  }

  Future<void> deleteEntry(String id) async {
    final response = await _apiClient.delete('/gratitude/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao apagar entrada');
    }
  }
}

final gratitudeServiceProvider = Provider<GratitudeService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GratitudeService(apiClient);
});
