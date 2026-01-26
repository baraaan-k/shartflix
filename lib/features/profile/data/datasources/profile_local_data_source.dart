import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ProfileLocalDataSource {
  static const _profileFileName = 'shartflix_profile.json';
  static const _avatarKey = 'avatarPath';
  static const _emailKey = 'email';
  static const _nameKey = 'name';

  Future<ProfileLocalData> readProfile() async {
    final file = await _profileFile();
    if (!await file.exists()) {
      return const ProfileLocalData();
    }
    final contents = await file.readAsString();
    if (contents.trim().isEmpty) {
      return const ProfileLocalData();
    }
    final decoded = jsonDecode(contents);
    if (decoded is! Map) {
      return const ProfileLocalData();
    }
    final map = Map<String, dynamic>.from(decoded);
    return ProfileLocalData(
      email: map[_emailKey] as String?,
      name: map[_nameKey] as String?,
      avatarPath: map[_avatarKey] as String?,
    );
  }

  Future<String> saveAvatar(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName =
        'avatar_${DateTime.now().millisecondsSinceEpoch}${_fileExtension(imageFile.path)}';
    final targetPath = '${directory.path}/$fileName';
    final savedFile = await imageFile.copy(targetPath);
    final profile = await readProfile();
    await _writeProfile(profile.copyWith(avatarPath: savedFile.path));
    return savedFile.path;
  }

  Future<void> saveUserInfo({
    required String email,
    String? name,
  }) async {
    final profile = await readProfile();
    await _writeProfile(
      profile.copyWith(
        email: email,
        name: name,
      ),
    );
  }

  Future<void> clearProfile() async {
    final file = await _profileFile();
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File> _profileFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_profileFileName');
  }

  String _fileExtension(String path) {
    final index = path.lastIndexOf('.');
    if (index == -1) return '';
    return path.substring(index);
  }

  Future<void> _writeProfile(ProfileLocalData data) async {
    final file = await _profileFile();
    final payload = jsonEncode(data.toJson());
    await file.writeAsString(payload);
  }
}

class ProfileLocalData {
  const ProfileLocalData({
    this.email,
    this.name,
    this.avatarPath,
  });

  final String? email;
  final String? name;
  final String? avatarPath;

  ProfileLocalData copyWith({
    String? email,
    String? name,
    String? avatarPath,
  }) {
    return ProfileLocalData(
      email: email ?? this.email,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ProfileLocalDataSource._emailKey: email,
      ProfileLocalDataSource._nameKey: name,
      ProfileLocalDataSource._avatarKey: avatarPath,
    };
  }
}
