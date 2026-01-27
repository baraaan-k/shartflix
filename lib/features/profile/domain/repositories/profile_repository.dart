import 'dart:io';

import '../entities/profile_user.dart';

abstract class ProfileRepository {
  Future<ProfileUser> getProfile();

  Future<ProfileUser> setAvatar(File imageFile);

  Future<ProfileUser> clearAvatar();

  Future<void> clearProfile();

  Future<ProfileUser> fetchRemoteProfile();

  Future<String> uploadPhoto(File imageFile);
}
