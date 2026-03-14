import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/domain/auth_provider.dart';

class ApiClient {
  final String baseUrl;
  final String? token;

  ApiClient({required this.baseUrl, this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<http.Response> get(String endpoint) async {
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> patch(String endpoint, Map<String, dynamic> body) async {
    return await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String endpoint) async {

    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final authState = ref.watch(authProvider);
  // Use 10.0.2.2 for Android emulator to access the host machine's localhost
  const baseUrl = 'http://10.0.2.2:3000';
  return ApiClient(baseUrl: baseUrl, token: authState.token);
});
