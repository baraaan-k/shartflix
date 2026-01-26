import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ProfileLocalDataSource {
  static const _profileFileName = 'shartflix_profile.json';
  static const _avatarKey = 'avatarPath';
  static const _emailKey = 'email';
  static const _nameKey = 'name';

  static const _avatarDirName = 'profile';
  static const _avatarRelPath = 'profile/avatar.jpg';

  Future<ProfileLocalData> readProfile() async {
    final docs = await getApplicationDocumentsDirectory();
    final file = File('${docs.path}/$_profileFileName');

    debugPrint('[Profile] docsDir: ${docs.path}');
    debugPrint('[Profile] profileJson: ${file.path}');

    if (!await file.exists()) return const ProfileLocalData();

    final contents = await file.readAsString();
    if (contents.trim().isEmpty) return const ProfileLocalData();

    final decoded = jsonDecode(contents);
    if (decoded is! Map) return const ProfileLocalData();

    final map = Map<String, dynamic>.from(decoded);

    final stored = (map[_avatarKey] as String?)?.trim();
    debugPrint('[Profile] loaded avatarPath(raw): $stored');

    String? relPath;
    if (stored != null && stored.isNotEmpty) {
      if (stored.startsWith('/')) {
        if (stored.startsWith(docs.path)) {
          final trimmed = stored.substring(docs.path.length);
          relPath = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
        } else {
          relPath = _avatarRelPath;
        }
      } else {
        relPath = stored;
      }
    }

    String? resolvedAbs;
    if (relPath != null && relPath.isNotEmpty) {
      final abs = '${docs.path}/$relPath';
      final exists = await File(abs).exists();
      debugPrint('[Profile] avatar abs: $abs');
      debugPrint('[Profile] avatar exists: $exists');
      if (exists) {
        resolvedAbs = abs;
      } else {
        final stableAbs = '${docs.path}/$_avatarRelPath';
        final stableExists = await File(stableAbs).exists();
        debugPrint('[Profile] stable avatar abs: $stableAbs');
        debugPrint('[Profile] stable avatar exists: $stableExists');
        if (stableExists) {
          resolvedAbs = stableAbs;
          relPath = _avatarRelPath;
        } else {
          relPath = null;
        }
      }
    } else {
      final stableAbs = '${docs.path}/$_avatarRelPath';
      final stableExists = await File(stableAbs).exists();
      debugPrint('[Profile] stable avatar abs: $stableAbs');
      debugPrint('[Profile] stable avatar exists: $stableExists');
      if (stableExists) {
        resolvedAbs = stableAbs;
        relPath = _avatarRelPath;
      }
    }

    final currentStored = (map[_avatarKey] as String?)?.trim();
    final normalizedToStore = relPath;
    if (currentStored != normalizedToStore) {
      final fixed = ProfileLocalData(
        email: map[_emailKey] as String?,
        name: map[_nameKey] as String?,
        avatarPath: normalizedToStore,
      );
      await _writeProfile(fixed);
      debugPrint('[Profile] normalized avatarPath written: $normalizedToStore');
    }

    return ProfileLocalData(
      email: map[_emailKey] as String?,
      name: map[_nameKey] as String?,
      avatarPath: resolvedAbs,
    );
  }

  Future<String> saveAvatar(File imageFile) async {
    final docs = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${docs.path}/$_avatarDirName');
    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }

    final targetAbs = '${docs.path}/$_avatarRelPath';

    debugPrint('[Profile] picked path: ${imageFile.path}');
    debugPrint('[Profile] saving to: $targetAbs');

    final bytes = await imageFile.readAsBytes();
    final targetFile = File(targetAbs);
    await targetFile.writeAsBytes(bytes, flush: true);

    final exists = await targetFile.exists();
    debugPrint('[Profile] saved exists: $exists');

    final profile = await readProfile();
    await _writeProfile(profile.copyWith(avatarPath: _avatarRelPath));
    return targetAbs;
  }

  Future<void> saveUserInfo({
    required String email,
    String? name,
  }) async {
    final profile = await readProfile();
    await _writeProfile(profile.copyWith(email: email, name: name));
  }

  Future<void> clearProfile() async {
    final docs = await getApplicationDocumentsDirectory();
    final file = File('${docs.path}/$_profileFileName');
    if (await file.exists()) {
      await file.delete();
    }
    final avatar = File('${docs.path}/$_avatarRelPath');
    if (await avatar.exists()) {
      await avatar.delete();
    }
  }

  Future<void> _writeProfile(ProfileLocalData data) async {
    final docs = await getApplicationDocumentsDirectory();
    final file = File('${docs.path}/$_profileFileName');

    String? toStore = data.avatarPath;
    if (toStore != null && toStore.startsWith(docs.path)) {
      final trimmed = toStore.substring(docs.path.length);
      toStore = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    }

    final payload = jsonEncode({
      _emailKey: data.email,
      _nameKey: data.name,
      _avatarKey: toStore,
    });

    await file.writeAsString(payload, flush: true);
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

  static const _unset = Object();

  ProfileLocalData copyWith({
    String? email,
    String? name,
    Object? avatarPath = _unset,
  }) {
    return ProfileLocalData(
      email: email ?? this.email,
      name: name ?? this.name,
      avatarPath: avatarPath == _unset ? this.avatarPath : avatarPath as String?,
    );
  }
}
