import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class AgreementsService {
  final ApiClient _apiClient;

  AgreementsService(this._apiClient);

  Future<List<dynamic>> getAgreements(String relationshipId) async {
    final response = await _apiClient.get('/agreements/relationship/$relationshipId');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao buscar os acordos/regras');
    }
  }

  Future<void> proposeAgreement({
    required String relationshipId,
    required String title,
    String? description,
  }) async {
    final response = await _apiClient.post(
      '/agreements',
      {
        'relationship_id': relationshipId,
        'title': title,
        'description': description,
      },
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Falha ao propor novo acordo');
    }
  }

  Future<void> agreeToRule(String agreementId) async {
    final response = await _apiClient.patch('/agreements/$agreementId/agree', {});
    if (response.statusCode != 200) {
      throw Exception('Falha ao aceitar o acordo');
    }
  }

  Future<void> deleteAgreement(String agreementId) async {
    final response = await _apiClient.delete('/agreements/$agreementId');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao eliminar o acordo');
    }
  }
}

final agreementsServiceProvider = Provider<AgreementsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AgreementsService(apiClient);
});
