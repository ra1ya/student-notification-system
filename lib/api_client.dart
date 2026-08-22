import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

enum ApiAuth { none, admin, student }

class ApiClient {
  static const Duration requestTimeout = Duration(seconds: 10);

  static String? _adminToken;
  static String? _studentToken;

  static void setAdminToken(String token) {
    _adminToken = token;
  }

  static void setStudentToken(String token) {
    _studentToken = token;
  }

  static void clearAdminToken() {
    _adminToken = null;
  }

  static void clearStudentToken() {
    _studentToken = null;
  }

  static Future<http.Response> post(
    String path, {
    Map<String, String>? body,
    ApiAuth auth = ApiAuth.none,
  }) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    final token = switch (auth) {
      ApiAuth.admin => _adminToken,
      ApiAuth.student => _studentToken,
      ApiAuth.none => null,
    };

    if (auth != ApiAuth.none) {
      if (token == null || token.isEmpty) {
        throw StateError('Authentication token is missing.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return http
        .post(
          ApiConfig.endpoint(path),
          headers: headers,
          body: body,
        )
        .timeout(requestTimeout);
  }

  static Map<String, dynamic> decodeObject(String responseBody) {
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object.');
    }
    return decoded;
  }

  static List<Map<String, dynamic>> decodeMessages(String responseBody) {
    final payload = decodeObject(responseBody);
    final rawMessages = payload['messages'];

    if (rawMessages is! List) {
      throw const FormatException('Expected a messages array.');
    }

    return rawMessages
        .whereType<Map<String, dynamic>>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
}
