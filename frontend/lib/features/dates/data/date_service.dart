import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class DateService {
  final ApiClient _apiClient;

  DateService(this._apiClient);

  Future<Map<String, dynamic>> getDateSuggestions(String relationshipId) async {
    final response = await _apiClient.get('/dates/suggestions/$relationshipId?lang=pt');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao obter sugestões de encontros');
    }
  }
}

final dateServiceProvider = Provider<DateService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DateService(apiClient);
});
