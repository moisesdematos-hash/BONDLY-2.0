import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/wishlist_service.dart';

class WishlistState {
  final List<dynamic> wishlists;
  final bool isLoading;
  final String? error;

  WishlistState({
    this.wishlists = const [],
    this.isLoading = false,
    this.error,
  });

  WishlistState copyWith({
    List<dynamic>? wishlists,
    bool? isLoading,
    String? error,
  }) {
    return WishlistState(
      wishlists: wishlists ?? this.wishlists,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class WishlistNotifier extends StateNotifier<WishlistState> {
  final WishlistService _wishlistService;

  WishlistNotifier(this._wishlistService) : super(WishlistState());

  Future<void> fetchWishlists(String relationshipId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final wishlists = await _wishlistService.getWishlists(relationshipId);
      state = state.copyWith(wishlists: wishlists, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addWishlist(
      String relationshipId, String title, String? description, String? linkUrl) async {
    try {
      final newItem = await _wishlistService.createWishlist(relationshipId, title, description, linkUrl);
      state = state.copyWith(wishlists: [newItem, ...state.wishlists]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markAsPurchased(String id) async {
    try {
      final updatedItem = await _wishlistService.markAsPurchased(id);
      state = state.copyWith(
        wishlists: state.wishlists.map((w) => w['id'] == id ? updatedItem : w).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeWishlist(String id) async {
    try {
      await _wishlistService.deleteWishlist(id);
      state = state.copyWith(
        wishlists: state.wishlists.where((w) => w['id'] != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {
  final service = ref.watch(wishlistServiceProvider);
  return WishlistNotifier(service);
});
