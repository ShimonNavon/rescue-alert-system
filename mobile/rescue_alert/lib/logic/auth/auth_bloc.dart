import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/auth_service.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthSignOutRequested extends AuthEvent {}

class _AuthUserChanged extends AuthEvent {
  const _AuthUserChanged(this.user);

  final User? user;

  @override
  List<Object?> get props => [user?.uid];
}

class AuthState extends Equatable {
  const AuthState({
    required this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  final User? user;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  AuthState copyWith({User? user, bool? isLoading, String? errorMessage}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [user?.uid, isLoading, errorMessage];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthService authService})
    : _authService = authService,
      super(AuthState(user: authService.currentUser)) {
    on<AuthStarted>(_onStarted);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignOutRequested>(_onSignOut);
    on<_AuthUserChanged>(_onUserChanged);
  }

  final AuthService _authService;
  StreamSubscription<User?>? _authSub;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    _authSub?.cancel();
    _authSub = _authService.authStateChanges.listen(
      (user) => add(_AuthUserChanged(user)),
    );
  }

  Future<void> _onSignIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _authService.signIn(email: event.email, password: event.password);
      emit(state.copyWith(isLoading: false, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.signOut();
  }

  void _onUserChanged(_AuthUserChanged event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(user: event.user, isLoading: false, errorMessage: null),
    );
  }

  @override
  Future<void> close() async {
    await _authSub?.cancel();
    return super.close();
  }
}
