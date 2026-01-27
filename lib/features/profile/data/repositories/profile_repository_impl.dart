import 'dart:io';

import '../../domain/entities/profile_user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileLocalDataSource profileLocalDataSource,
    required ProfileRemoteDataSource profileRemoteDataSource,
  })  : _profileLocalDataSource = profileLocalDataSource,
        _profileRemoteDataSource = profileRemoteDataSource;

  final ProfileLocalDataSource _profileLocalDataSource;
  final ProfileRemoteDataSource _profileRemoteDataSource;

  @override
  Future<ProfileUser> getProfile() async {
    final data = await _profileLocalDataSource.readProfile();
    return ProfileUser(
      email: data.email ?? '',
      name: data.name,
      avatarPath: data.avatarPath,
      photoUrl: data.photoUrl,
    );
  }

  @override
  Future<ProfileUser> setAvatar(File imageFile) async {
    await _profileLocalDataSource.saveAvatar(imageFile);
    return getProfile();
  }

  @override
  Future<ProfileUser> clearAvatar() async {
    await _profileLocalDataSource.clearAvatar();
    return getProfile();
  }

  @override
  Future<void> clearProfile() {
    return _profileLocalDataSource.clearProfile();
  }

  @override
  Future<ProfileUser> fetchRemoteProfile() async {
    final remote = await _profileRemoteDataSource.fetchProfile();
    await _profileLocalDataSource.saveUserInfo(
      email: remote.email,
      name: remote.name,
    );
    if (remote.photoUrl != null && remote.photoUrl!.isNotEmpty) {
      await _profileLocalDataSource.savePhotoUrl(remote.photoUrl!);
    }
    return getProfile();
  }

  @override
  Future<String> uploadPhoto(File imageFile) async {
    final photoUrl = await _profileRemoteDataSource.uploadPhoto(imageFile);
    await _profileLocalDataSource.savePhotoUrl(photoUrl);
    return photoUrl;
  }
}
