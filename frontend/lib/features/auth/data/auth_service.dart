import 'dart:convert';
import '../../../core/network/api_client.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService({required this.apiClient});

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await apiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Falha no login');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String language = 'pt',
  }) async {
    final response = await apiClient.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'language': language,
    });

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Falha no registro');
    }
  }

  Future<void> deleteAccount() async {
    final response = await apiClient.delete('/users/me');
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Falha ao excluir conta');
    }
  }
}

