import 'dart:async';

import 'package:rescue_app/domain/models/auth_user.dart';
import 'package:rescue_app/domain/services/api/rest_api_service.dart';
import 'package:rescue_app/managers/storage_manager.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();

  AuthUser? _currentUser;

  AuthUser? get currentUser => _currentUser;

  Stream<AuthUser?> get authStateChanges => _controller.stream;

  Future<void> restore() async {
    final identity = await StorageManager.instance.getBearer();
    if (identity == null || identity.accessToken.isEmpty) {
      _emit(null);
      return;
    }

    await RestApiService().setAccessAuthToken(access: identity.accessToken);
    try {
      final user = await RestApiService().fetchCurrentUser();
      _emit(user);
    } catch (_) {
      await StorageManager.instance.clearTokens();
      RestApiService().clearTokens();
      _emit(null);
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await RestApiService().obtainToken(username: email, password: password);
    try {
      final user = await RestApiService().fetchCurrentUser();
      _emit(user);
    } catch (_) {
      await RestApiService().logout();
      _emit(null);
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    String fullName = '',
    String inviteCode = '',
  }) async {
    await RestApiService().register(
      email: email,
      password: password,
      fullName: fullName,
      inviteCode: inviteCode,
    );
    try {
      final user = await RestApiService().fetchCurrentUser();
      _emit(user);
    } catch (_) {
      await RestApiService().logout();
      _emit(null);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await RestApiService().logout();
    _emit(null);
  }

  /// Test-only hook so widget tests can start from an authenticated state.
  void debugSetUser(AuthUser? user) => _emit(user);

  void _emit(AuthUser? user) {
    _currentUser = user;
    if (!_controller.isClosed) {
      _controller.add(user);
    }
  }
}
