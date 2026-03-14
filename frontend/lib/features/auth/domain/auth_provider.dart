import '../../../core/network/api_client.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient: apiClient);
});


class AuthState {
  final bool isLoading;
  final String? token;
  final Map<String, dynamic>? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.token,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    String? token,
    Map<String, dynamic>? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authService.login(email, password);
      state = state.copyWith(
        isLoading: false,
        token: result['access_token'],
        user: result['user'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.register(name: name, email: email, password: password);
      await login(email, password);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile({String? name, String? language}) async {
    // This is a bit of a shortcut. A separate ProfileProvider might be cleaner
    // but AuthProvider owns the 'user' state currently.
    state = state.copyWith(isLoading: true, error: null);
    try {
      // We need to fetch the service here or pass it in.
      // Since AuthNotifier is created with AuthService, and ProfileService uses ApiClient,
      // it might be better to just make the request here or refactor.
      // For now, I'll update the user state directly if passed from the UI.
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateUserState(Map<String, dynamic> newUser) {
    state = state.copyWith(user: newUser);
  }

  void logout() {
    state = AuthState();
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.deleteAccount();
      logout();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}


final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
