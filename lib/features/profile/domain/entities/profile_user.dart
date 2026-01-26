class ProfileUser {
  const ProfileUser({
    required this.email,
    this.name,
    this.avatarPath,
  });

  final String email;
  final String? name;
  final String? avatarPath;
}
