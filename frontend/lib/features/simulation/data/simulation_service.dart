import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class SimulationService {
  final ApiClient _apiClient;

  SimulationService(this._apiClient);

  Future<Map<String, dynamic>> simulateMessage({
    required String message,
    required String relationshipType,
  }) async {
    final response = await _apiClient.post(
      '/simulation',
      {
        'message': message,
        'relationshipType': relationshipType,
      },
    );


    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao simular mensagem');
    }
  }

  Future<List<dynamic>> getSimulations() async {
    final response = await _apiClient.get('/simulation/history');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Falha ao buscar histórico de simulações');
    }
  }
}

final simulationServiceProvider = Provider<SimulationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SimulationService(apiClient);
});
