// lib/core/services/api_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
    // final String baseUrl = dotenv.env['BASE_URL'] ?? 'default_url';

  final String baseUrl = dotenv.env['BASE_URL'] ?? 'default_url';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Map<String, String> _buildHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  Future<Map<String, String>> _getHeaders() async {
    final headers = _buildHeaders();
    final token = await getToken();

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return http.get(uri, headers: headers);
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool useAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    print('POST Request to: $uri with body: $body');
    final headers = await _getHeaders();
    return http.post(uri, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool useAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return http.put(uri, headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> delete(String endpoint, {bool useAuth = false}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    return http.delete(uri, headers: headers);
  }
}
