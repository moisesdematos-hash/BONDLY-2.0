import '../../../core/network/api_client.dart';

final relationshipServiceProvider = Provider<RelationshipService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RelationshipService(
    apiClient: apiClient,
  );
});


class RelationshipState {
  final bool isLoading;
  final List<Map<String, dynamic>> relationships;
  final Map<String, dynamic>? selectedRelationship;
  final String? lastCreatedInviteCode;
  final String? error;

  RelationshipState({
    this.isLoading = false,
    this.relationships = const [],
    this.selectedRelationship,
    this.lastCreatedInviteCode,
    this.error,
  });

  RelationshipState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? relationships,
    Map<String, dynamic>? selectedRelationship,
    String? lastCreatedInviteCode,
    String? error,
  }) {
    return RelationshipState(
      isLoading: isLoading ?? this.isLoading,
      relationships: relationships ?? this.relationships,
      selectedRelationship: selectedRelationship ?? this.selectedRelationship,
      lastCreatedInviteCode: lastCreatedInviteCode ?? this.lastCreatedInviteCode,
      error: error ?? this.error,
    );
  }
}

class RelationshipNotifier extends StateNotifier<RelationshipState> {
  final RelationshipService _service;

  RelationshipNotifier(this._service) : super(RelationshipState());

  Future<void> fetchRelationships() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final relationships = await _service.getRelationships();
      state = state.copyWith(
        isLoading: false,
        relationships: relationships,
        selectedRelationship: state.selectedRelationship ?? (relationships.isNotEmpty ? relationships.first : null),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectRelationship(Map<String, dynamic> relationship) {
    state = state.copyWith(selectedRelationship: relationship);
  }

  Future<void> createRelationship(String type, String name) async {
    state = state.copyWith(isLoading: true, error: null, lastCreatedInviteCode: null);
    try {
      final relationship = await _service.createRelationship(type, name);
      state = state.copyWith(
        isLoading: false,
        lastCreatedInviteCode: relationship['invite_code'],
      );
      await fetchRelationships();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> joinRelationship(String inviteCode) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.joinRelationship(inviteCode);
      await fetchRelationships();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final relationshipProvider = StateNotifierProvider<RelationshipNotifier, RelationshipState>((ref) {
  final service = ref.watch(relationshipServiceProvider);
  return RelationshipNotifier(service);
});
