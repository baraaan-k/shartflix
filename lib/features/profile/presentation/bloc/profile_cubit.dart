import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';

import '../../domain/usecases/fetch_profile_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/clear_avatar_usecase.dart';
import '../../domain/usecases/set_avatar_usecase.dart';
import '../../domain/usecases/upload_photo_usecase.dart';
import 'profile_state.dart';

class ProfileCubit {
  ProfileCubit({
    required GetProfileUseCase getProfileUseCase,
    required SetAvatarUseCase setAvatarUseCase,
    required ClearAvatarUseCase clearAvatarUseCase,
    required FetchProfileUseCase fetchProfileUseCase,
    required UploadPhotoUseCase uploadPhotoUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _setAvatarUseCase = setAvatarUseCase,
        _clearAvatarUseCase = clearAvatarUseCase,
        _fetchProfileUseCase = fetchProfileUseCase,
        _uploadPhotoUseCase = uploadPhotoUseCase;

  final GetProfileUseCase _getProfileUseCase;
  final SetAvatarUseCase _setAvatarUseCase;
  final ClearAvatarUseCase _clearAvatarUseCase;
  final FetchProfileUseCase _fetchProfileUseCase;
  final UploadPhotoUseCase _uploadPhotoUseCase;

  final StreamController<ProfileState> _controller =
      StreamController<ProfileState>.broadcast();
  ProfileState _state = const ProfileState();

  Stream<ProfileState> get stream => _controller.stream;

  ProfileState get state => _state;

  void _emit(ProfileState state) {
    _state = state;
    _controller.add(state);
  }

  Future<void> load() async {
    if (_state.isLoading) return;
    _emit(_state.copyWith(isLoading: true, errorMessage: null));
    try {
      try {
        await _fetchProfileUseCase();
      } catch (_) {}
      final user = await _getProfileUseCase();
      _emit(_state.copyWith(user: user, isLoading: false));
    } catch (error) {
      _emit(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load profile.',
        ),
      );
    }
  }

  Future<void> setAvatar(File imageFile) async {
    if (_state.isUpdatingAvatar) return;
    _emit(_state.copyWith(isUpdatingAvatar: true, errorMessage: null));
    try {
      final user = await _setAvatarUseCase(imageFile);
      if (user.avatarPath != null && user.avatarPath!.isNotEmpty) {
        await FileImage(File(user.avatarPath!)).evict();
      }
      _emit(
        _state.copyWith(
          user: user,
          avatarRevision: DateTime.now().microsecondsSinceEpoch,
        ),
      );
      try {
        await _uploadPhotoUseCase(imageFile);
        final updated = await _getProfileUseCase();
        _emit(
          _state.copyWith(
            user: updated,
            avatarRevision: DateTime.now().microsecondsSinceEpoch,
          ),
        );
      } catch (error) {
        _emit(
          _state.copyWith(
            errorMessage: error.toString(),
          ),
        );
      } finally {
        _emit(_state.copyWith(isUpdatingAvatar: false));
      }
    } catch (error) {
      _emit(
        _state.copyWith(
          isUpdatingAvatar: false,
          errorMessage: 'Failed to update avatar.',
        ),
      );
    }
  }

  Future<void> clearAvatar() async {
    if (_state.isUpdatingAvatar) return;
    _emit(_state.copyWith(isUpdatingAvatar: true, errorMessage: null));
    try {
      final user = await _clearAvatarUseCase();
      _emit(
        _state.copyWith(
          user: user,
          avatarRevision: DateTime.now().microsecondsSinceEpoch,
        ),
      );
    } catch (error) {
      _emit(
        _state.copyWith(
          errorMessage: 'Failed to remove avatar.',
        ),
      );
    } finally {
      _emit(_state.copyWith(isUpdatingAvatar: false));
    }
  }

  void close() {
    _controller.close();
  }
}
