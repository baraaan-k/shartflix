import 'dart:async';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

class AuthCubit {
  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase;

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;

  final StreamController<AuthState> _controller =
      StreamController<AuthState>.broadcast();
  AuthState _state = const AuthState();

  Stream<AuthState> get stream => _controller.stream;

  AuthState get state => _state;

  void _emit(AuthState state) {
    _state = state;
    _controller.add(state);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _emit(_state.copyWith(status: AuthStatus.loading, message: null));
    try {
      await _loginUseCase(email: email, password: password);
      _emit(_state.copyWith(status: AuthStatus.authenticated));
    } catch (error) {
      _emit(
        _state.copyWith(
          status: AuthStatus.error,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _emit(_state.copyWith(status: AuthStatus.loading, message: null));
    try {
      await _registerUseCase(name: name, email: email, password: password);
      _emit(_state.copyWith(status: AuthStatus.authenticated));
    } catch (error) {
      _emit(
        _state.copyWith(
          status: AuthStatus.error,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> logout() async {
    await _logoutUseCase();
    _emit(const AuthState(status: AuthStatus.idle));
  }

  void close() {
    _controller.close();
  }
}
