import '../repositories/auth_repository.dart';

class GetTokenUseCase {
  GetTokenUseCase(this._repository);

  final AuthRepository _repository;

  Future<String?> call() {
    return _repository.getToken();
  }
}
