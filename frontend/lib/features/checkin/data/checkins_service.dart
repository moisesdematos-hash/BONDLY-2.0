import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class CheckinsService {
  final ApiClient _apiClient;

  CheckinsService(this._apiClient);

  Future<void> saveCheckin({
    required String relationshipId,
    required int mood,
    String? note,
  }) async {
    final response = await _apiClient.post(
      '/checkins',
      {
        'relationship_id': relationshipId,
        'mood': mood,
        'note': note,
      },
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Falha ao salvar check-in');
    }
  }

  Future<List<dynamic>> getHistory(String relationshipId) async {
    final response = await _apiClient.get('/checkins/relationship/$relationshipId');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao buscar histórico de check-ins');
    }
  }

  Future<bool> getPartnerStatus(String relationshipId) async {
    final response = await _apiClient.get('/checkins/partner-status/$relationshipId');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['partner_checked_in'] ?? false;
    } else {
      throw Exception('Falha ao buscar status do parceiro');
    }
  }
}

final checkinsServiceProvider = Provider<CheckinsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CheckinsService(apiClient);
});
