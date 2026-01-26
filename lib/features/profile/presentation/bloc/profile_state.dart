import '../../domain/entities/profile_user.dart';

class ProfileState {
  const ProfileState({
    this.user,
    this.isLoading = false,
    this.isUpdatingAvatar = false,
    this.avatarRevision = 0,
    this.errorMessage,
  });

  final ProfileUser? user;
  final bool isLoading;
  final bool isUpdatingAvatar;
  final int avatarRevision;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileUser? user,
    bool? isLoading,
    bool? isUpdatingAvatar,
    int? avatarRevision,
    String? errorMessage,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isUpdatingAvatar: isUpdatingAvatar ?? this.isUpdatingAvatar,
      avatarRevision: avatarRevision ?? this.avatarRevision,
      errorMessage: errorMessage,
    );
  }
}
