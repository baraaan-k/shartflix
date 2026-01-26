enum AuthStatus {
  idle,
  loading,
  authenticated,
  error,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.idle,
    this.message,
  });

  final AuthStatus status;
  final String? message;

  AuthState copyWith({
    AuthStatus? status,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      message: message,
    );
  }
}
