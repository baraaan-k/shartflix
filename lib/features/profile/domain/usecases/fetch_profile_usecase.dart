import '../entities/profile_user.dart';
import '../repositories/profile_repository.dart';

class FetchProfileUseCase {
  FetchProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileUser> call() {
    return _repository.fetchRemoteProfile();
  }
}
