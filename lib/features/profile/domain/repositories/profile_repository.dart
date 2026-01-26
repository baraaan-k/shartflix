import 'dart:io';

import '../entities/profile_user.dart';

abstract class ProfileRepository {
  Future<ProfileUser> getProfile();

  Future<ProfileUser> setAvatar(File imageFile);

  Future<void> clearProfile();
}
