abstract class AuthRemoteDataSource {
  Future<String> login({
    required String email,
    required String password,
  });

  Future<String> register({
    required String name,
    required String email,
    required String password,
  });
}

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Missing credentials');
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return 'dummy_token';
  }

  @override
  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('Missing registration details');
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return 'dummy_token';
  }
}
