import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final token = await _remote.login(email: email, password: password);
    await _local.saveToken(token);
    return token;
  }

  @override
  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final token = await _remote.register(
      name: name,
      email: email,
      password: password,
    );
    await _local.saveToken(token);
    return token;
  }

  @override
  Future<String?> getToken() {
    return _local.getToken();
  }

  @override
  Future<void> saveToken(String token) {
    return _local.saveToken(token);
  }

  @override
  Future<void> clearToken() {
    return _local.clearToken();
  }
}
