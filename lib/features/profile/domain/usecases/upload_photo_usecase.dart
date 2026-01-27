import 'dart:io';

import '../repositories/profile_repository.dart';

class UploadPhotoUseCase {
  UploadPhotoUseCase(this._repository);

  final ProfileRepository _repository;

  Future<String> call(File imageFile) {
    return _repository.uploadPhoto(imageFile);
  }
}
