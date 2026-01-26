import 'dart:io';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/profile_user.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<ProfileUser> fetchProfile() async {
    final response = await _apiClient.getJson('/user/profile');
    final envelope = _parseEnvelope(response);
    final data = _extractUserData(envelope);
    return ProfileUser(
      email: data['email'] as String? ?? '',
      name: data['name'] as String?,
      photoUrl: data['photoUrl'] as String?,
    );
  }

  Future<String> uploadPhoto(File file) async {
    final response = await _apiClient.postMultipart('/user/upload_photo', file);
    final envelope = _parseEnvelope(response);
    final data = envelope['data'];
    if (data is Map) {
      final photoUrl = data['photoUrl'] ?? data['url'];
      if (photoUrl is String && photoUrl.isNotEmpty) {
        return photoUrl;
      }
    }
    throw ApiException(0, 'UPLOAD_FAILED');
  }

  Map<String, dynamic> _parseEnvelope(Map<String, dynamic> json) {
    final response = json['response'];
    int? code;
    String message = '';
    if (response is Map) {
      code = response['code'] as int?;
      message = response['message'] as String? ?? '';
    }
    if (code != 200 && code != 201) {
      throw ApiException(code ?? 0, message.isNotEmpty ? message : 'ERROR');
    }
    return json;
  }

  Map<String, dynamic> _extractUserData(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map && data['user'] is Map) {
      return Map<String, dynamic>.from(data['user'] as Map);
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }
}
