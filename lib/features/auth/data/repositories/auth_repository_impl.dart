import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../../profile/data/datasources/profile_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    required ProfileLocalDataSource profileLocalDataSource,
  })  : _remote = remote,
        _local = local,
        _profileLocalDataSource = profileLocalDataSource;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final ProfileLocalDataSource _profileLocalDataSource;

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _remote.login(email: email, password: password);
    if (response.token.isEmpty) {
      throw Exception('Invalid token response');
    }
    await _local.saveToken(response.token);
    await _profileLocalDataSource.saveUserInfo(
      email: response.user.email.isNotEmpty ? response.user.email : email,
      name: response.user.name.isNotEmpty
          ? response.user.name
          : email.split('@').first,
    );
    return response.token;
  }

  @override
  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _remote.register(
      name: name,
      email: email,
      password: password,
    );
    if (response.token.isEmpty) {
      throw Exception('Invalid token response');
    }
    await _local.saveToken(response.token);
    await _profileLocalDataSource.saveUserInfo(
      email: response.user.email.isNotEmpty ? response.user.email : email,
      name: response.user.name.isNotEmpty ? response.user.name : name,
    );
    return response.token;
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
