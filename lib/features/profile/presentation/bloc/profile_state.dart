import '../../domain/entities/profile_user.dart';

class ProfileState {
  const ProfileState({
    this.user,
    this.isLoading = false,
    this.isUpdatingAvatar = false,
    this.errorMessage,
  });

  final ProfileUser? user;
  final bool isLoading;
  final bool isUpdatingAvatar;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileUser? user,
    bool? isLoading,
    bool? isUpdatingAvatar,
    String? errorMessage,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isUpdatingAvatar: isUpdatingAvatar ?? this.isUpdatingAvatar,
      errorMessage: errorMessage,
    );
  }
}
