class AuthUserModel {
  AuthUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? json['_id'];
    return AuthUserModel(
      id: id as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
    );
  }
}

class AuthResponseModel {
  AuthResponseModel({
    required this.token,
    required this.user,
  });

  final String token;
  final AuthUserModel user;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String? ?? '',
      user: AuthUserModel.fromJson(
        Map<String, dynamic>.from(json['user'] as Map? ?? {}),
      ),
    );
  }
}
