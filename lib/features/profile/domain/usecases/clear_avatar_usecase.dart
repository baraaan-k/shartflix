import '../entities/profile_user.dart';
import '../repositories/profile_repository.dart';

class ClearAvatarUseCase {
  ClearAvatarUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileUser> call() {
    return _repository.clearAvatar();
  }
}
