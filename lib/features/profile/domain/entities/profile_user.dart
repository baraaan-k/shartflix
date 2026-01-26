class ProfileUser {
  const ProfileUser({
    required this.email,
    this.name,
    this.avatarPath,
    this.photoUrl,
  });

  final String email;
  final String? name;
  final String? avatarPath;
  final String? photoUrl;
}
