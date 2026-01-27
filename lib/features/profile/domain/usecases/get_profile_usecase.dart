import '../entities/profile_user.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileUser> call() {
    return _repository.getProfile();
  }
}
