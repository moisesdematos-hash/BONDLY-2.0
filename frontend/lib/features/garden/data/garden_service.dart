import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class GardenService {
  final ApiClient _apiClient;

  GardenService(this._apiClient);

  Future<Map<String, dynamic>> getGardenStats(String relationshipId) async {
    final response = await _apiClient.get('/garden/$relationshipId');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao obter dados do jardim');
    }
  }
}

final gardenServiceProvider = Provider<GardenService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GardenService(apiClient);
});
