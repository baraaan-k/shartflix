import 'dart:io';

import '../entities/profile_user.dart';
import '../repositories/profile_repository.dart';

class SetAvatarUseCase {
  SetAvatarUseCase(this._repository);

  final ProfileRepository _repository;

  Future<ProfileUser> call(File imageFile) {
    return _repository.setAvatar(imageFile);
  }
}
