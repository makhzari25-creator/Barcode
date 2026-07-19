import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../injection.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';

/// وضعیت احراز هویت
@immutable
class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  factory AuthState.initial() => const AuthState();
  factory AuthState.loading() => const AuthState(isLoading: true);
  factory AuthState.authenticated(User user) =>
      AuthState(user: user, isAuthenticated: true);
  factory AuthState.error(String message) =>
      AuthState(errorMessage: message);
}

/// State Notifier برای احراز هویت
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthNotifier(this._loginUseCase, this._logoutUseCase, this._getCurrentUserUseCase)
      : super(AuthState.initial()) {
    _restoreSession();
  }

  /// بازگردانی نشست ذخیره‌شده
  Future<void> _restoreSession() async {
    try {
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        state = AuthState.authenticated(user);
      }
    } catch (_) {
      // ignore restore errors
    }
  }

  /// ورود به سیستم
  Future<bool> login({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    state = AuthState.loading();

    final result = await _loginUseCase(
      username: username,
      password: password,
      role: role,
    );

    if (result.isSuccess) {
      state = AuthState.authenticated(result.getOrNull()!);
      return true;
    }

    state = AuthState.error(result.getErrorOrNull()?.message ?? 'خطا در ورود');
    return false;
  }

  /// خروج از سیستم
  Future<void> logout() async {
    await _logoutUseCase();
    state = AuthState.initial();
  }

  /// پاک کردن پیام خطا
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}

/// Provider برای احراز هویت
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(loginUseCaseProvider),
    ref.watch(logoutUseCaseProvider),
    ref.watch(getCurrentUserUseCaseProvider),
  );
});

/// Provider برای دسترسی سریع به وضعیت احراز هویت
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authProvider);
});

/// Provider برای کاربر فعلی
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});
