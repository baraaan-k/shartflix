import '../../../../core/network/api_client.dart';
import '../../../../core/log/app_log.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();
    final response = await _apiClient.postJson(
      '/user/login',
      {
        'email': trimmedEmail,
        'password': trimmedPassword,
      },
      auth: false,
    );
    return _parseEnvelope(response);
  }

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedName = name.trim().isNotEmpty
        ? name.trim()
        : trimmedEmail.split('@').first;
    final trimmedPassword = password.trim();
    AppLog.d(
      'Auth',
      'register payload: email=$trimmedEmail name=$trimmedName password=$trimmedPassword',
    );
    final response = await _apiClient.postJson(
      '/user/register',
      {
        'email': trimmedEmail,
        'name': trimmedName,
        'password': trimmedPassword,
      },
      auth: false,
    );
    return _parseEnvelope(response);
  }

  AuthResponseModel _parseEnvelope(Map<String, dynamic> json) {
    final response = json['response'];
    int? code;
    String message = '';
    if (response is Map) {
      code = response['code'] as int?;
      message = response['message'] as String? ?? '';
    }
    final data = json['data'];
    if (code != 200 && code != 201) {
      throw ApiException(code ?? 0, message.isNotEmpty ? message : 'ERROR');
    }
    final dataMap =
        data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
    final token = dataMap['token'] as String? ?? json['token'] as String? ?? '';
    final userJson = dataMap['user'] is Map
        ? Map<String, dynamic>.from(dataMap['user'] as Map)
        : dataMap;
    final user = AuthUserModel.fromJson(userJson);
    return AuthResponseModel(token: token, user: user);
  }
}
