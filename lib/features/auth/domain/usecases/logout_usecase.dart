import '../../../profile/domain/repositories/profile_repository.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  LogoutUseCase(this._repository, this._profileRepository);

  final AuthRepository _repository;
  final ProfileRepository _profileRepository;

  Future<void> call() async {
    await _repository.clearToken();
    await _profileRepository.clearProfile();
  }
}
