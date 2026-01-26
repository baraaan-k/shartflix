import 'dart:async';
import 'dart:io';

import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/set_avatar_usecase.dart';
import 'profile_state.dart';

class ProfileCubit {
  ProfileCubit({
    required GetProfileUseCase getProfileUseCase,
    required SetAvatarUseCase setAvatarUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _setAvatarUseCase = setAvatarUseCase;

  final GetProfileUseCase _getProfileUseCase;
  final SetAvatarUseCase _setAvatarUseCase;

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
      _emit(_state.copyWith(user: user, isUpdatingAvatar: false));
    } catch (error) {
      _emit(
        _state.copyWith(
          isUpdatingAvatar: false,
          errorMessage: 'Failed to update avatar.',
        ),
      );
    }
  }

  void close() {
    _controller.close();
  }
}
