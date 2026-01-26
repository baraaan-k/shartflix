import 'dart:convert';
import 'dart:io';

import '../log/app_log.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    required AuthLocalDataSource authLocalDataSource,
    HttpClient? httpClient,
  })  : _authLocalDataSource = authLocalDataSource,
        _httpClient = httpClient ?? HttpClient();

  static const String baseUrl = 'https://caseapi.servicelabs.tech';

  final AuthLocalDataSource _authLocalDataSource;
  final HttpClient _httpClient;

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    bool auth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = await _httpClient.postUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    if (auth) {
      final token = await _authLocalDataSource.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
    }
    final payload = jsonEncode(body);
    AppLog.d('Api', 'POST $path');
    request.add(utf8.encode(payload));
    final response = await request.close();
    return _handleResponse(response, path);
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    bool auth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = await _httpClient.getUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    if (auth) {
      final token = await _authLocalDataSource.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
    }
    AppLog.d('Api', 'GET $path');
    final response = await request.close();
    return _handleResponse(response, path);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path,
    File file, {
    String fieldName = 'file',
    bool auth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = await _httpClient.postUrl(uri);
    final boundary = '----shartflix-${DateTime.now().microsecondsSinceEpoch}';
    request.headers.set(
      HttpHeaders.contentTypeHeader,
      'multipart/form-data; boundary=$boundary',
    );
    if (auth) {
      final token = await _authLocalDataSource.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
    }
    AppLog.d('Api', 'POST $path (multipart)');
    final fileName = file.uri.pathSegments.last;
    request.add(utf8.encode('--$boundary\r\n'));
    request.add(utf8.encode(
      'Content-Disposition: form-data; name="$fieldName"; filename="$fileName"\r\n',
    ));
    request.add(utf8.encode('Content-Type: application/octet-stream\r\n\r\n'));
    request.add(await file.readAsBytes());
    request.add(utf8.encode('\r\n--$boundary--\r\n'));
    final response = await request.close();
    return _handleResponse(response, path);
  }

  Future<Map<String, dynamic>> _handleResponse(
    HttpClientResponse response,
    String path,
  ) async {
    final status = response.statusCode;
    final body = await response.transform(utf8.decoder).join();
    AppLog.d('Api', '$path -> $status body: $body');
    final decoded = _safeDecode(body);
    if (status < 200 || status >= 300) {
      final errorBody = body.trim();
      final extracted = _extractErrorMessage(decoded, errorBody);
      final message = extracted ??
          (errorBody.isNotEmpty
              ? errorBody
              : 'Request failed with status $status');
      throw ApiException(status, message);
    }
    return decoded ?? <String, dynamic>{};
  }

  Map<String, dynamic>? _safeDecode(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return null;
  }

  String? _extractErrorMessage(Map<String, dynamic>? decoded, String body) {
    if (decoded == null) return body.isEmpty ? null : body;
    final response = decoded['response'];
    if (response is Map) {
      final msg = response['message'];
      if (msg is String && msg.isNotEmpty) {
        return msg;
      }
    }
    final message = decoded['message'] ?? decoded['error'];
    if (message is String && message.isNotEmpty) {
      return message;
    }
    return null;
  }
}
