import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class ProfileService {
  final ApiClient _apiClient;

  ProfileService(this._apiClient);

  Future<Map<String, dynamic>> getMe() async {
    final response = await _apiClient.get('/users/me');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao obter perfil');
    }
  }

  Future<Map<String, dynamic>> updateProfile({String? name, String? language}) async {
    final response = await _apiClient.patch('/users/me', {
      if (name != null) 'name': name,
      if (language != null) 'language': language,
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao atualizar perfil');
    }
  }
}

final profileServiceProvider = Provider<ProfileService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileService(apiClient);
});
