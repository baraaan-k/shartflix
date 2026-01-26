import 'dart:io';

import '../../domain/entities/profile_user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileLocalDataSource profileLocalDataSource,
  }) : _profileLocalDataSource = profileLocalDataSource;

  final ProfileLocalDataSource _profileLocalDataSource;

  @override
  Future<ProfileUser> getProfile() async {
    final data = await _profileLocalDataSource.readProfile();
    return ProfileUser(
      email: data.email ?? '',
      name: data.name,
      avatarPath: data.avatarPath,
    );
  }

  @override
  Future<ProfileUser> setAvatar(File imageFile) async {
    await _profileLocalDataSource.saveAvatar(imageFile);
    return getProfile();
  }

  @override
  Future<void> clearProfile() {
    return _profileLocalDataSource.clearProfile();
  }
}
