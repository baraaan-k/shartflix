import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<String?> getToken();

  Future<void> saveToken(String token);

  Future<void> clearToken();

  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._storage);

  static const _tokenKey = 'auth_token';
  static const IOSOptions iosOptions = IOSOptions();
  static const AndroidOptions androidOptions = AndroidOptions();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> getToken() {
    return _storage.read(
      key: _tokenKey,
      iOptions: iosOptions,
      aOptions: androidOptions,
    );
  }

  @override
  Future<void> saveToken(String token) {
    return _storage.write(
      key: _tokenKey,
      value: token,
      iOptions: iosOptions,
      aOptions: androidOptions,
    );
  }

  @override
  Future<void> clearToken() {
    return _storage.delete(
      key: _tokenKey,
      iOptions: iosOptions,
      aOptions: androidOptions,
    );
  }

  @override
  Future<void> clearAll() {
    return _storage.deleteAll(
      iOptions: iosOptions,
      aOptions: androidOptions,
    );
  }
}
