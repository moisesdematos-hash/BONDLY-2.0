import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/agreements_service.dart';

class AgreementsState {
  final bool isLoading;
  final List<dynamic> agreements;
  final String? error;

  AgreementsState({
    this.isLoading = false,
    this.agreements = const [],
    this.error,
  });

  AgreementsState copyWith({
    bool? isLoading,
    List<dynamic>? agreements,
    String? error,
  }) {
    return AgreementsState(
      isLoading: isLoading ?? this.isLoading,
      agreements: agreements ?? this.agreements,
      error: error ?? this.error,
    );
  }
}

class AgreementsNotifier extends StateNotifier<AgreementsState> {
  final AgreementsService _agreementsService;

  AgreementsNotifier(this._agreementsService) : super(AgreementsState());

  Future<void> fetchAgreements(String relationshipId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final agreements = await _agreementsService.getAgreements(relationshipId);
      state = state.copyWith(isLoading: false, agreements: agreements);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> proposeAgreement(String relationshipId, String title, String? description) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _agreementsService.proposeAgreement(
        relationshipId: relationshipId,
        title: title,
        description: description,
      );
      await fetchAgreements(relationshipId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> agreeToRule(String agreementId, String relationshipId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _agreementsService.agreeToRule(agreementId);
      await fetchAgreements(relationshipId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteAgreement(String agreementId, String relationshipId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _agreementsService.deleteAgreement(agreementId);
      await fetchAgreements(relationshipId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final agreementsProvider = StateNotifierProvider<AgreementsNotifier, AgreementsState>((ref) {
  final service = ref.watch(agreementsServiceProvider);
  return AgreementsNotifier(service);
});
