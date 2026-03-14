import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

class WishlistService {
  final ApiClient _apiClient;

  WishlistService(this._apiClient);

  Future<List<dynamic>> getWishlists(String relationshipId) async {
    final response = await _apiClient.get('/wishlists/$relationshipId');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao obter wishlists');
    }
  }

  Future<Map<String, dynamic>> createWishlist(
    String relationshipId,
    String title,
    String? description,
    String? linkUrl,
  ) async {
    final response = await _apiClient.post('/wishlists', {
      'relationship_id': relationshipId,
      'title': title,
      'description': description,
      'link_url': linkUrl,
    });
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao adicionar à wishlist');
    }
  }

  Future<Map<String, dynamic>> markAsPurchased(String wishlistId) async {
    final response = await _apiClient.put('/wishlists/$wishlistId/purchased', {});
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao marcar como comprado');
    }
  }

  Future<void> deleteWishlist(String id) async {
    final response = await _apiClient.delete('/wishlists/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao remover item da wishlist');
    }
  }
}

final wishlistServiceProvider = Provider<WishlistService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WishlistService(apiClient);
});
