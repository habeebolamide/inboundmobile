// lib/core/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const baseUrl = 'http://127.0.0.1:8000/api';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<Map<String, String>> _getHeaders({bool useAuth = false}) async {
    final headers = _buildHeaders();
    if (useAuth) {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No token found in local storage');
      }
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }


  Future<http.Response> get(String endpoint, {bool useAuth = false}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(useAuth: useAuth);
    return http.get(uri, headers: headers);
  }

  Future<http.Response> post(String endpoint,
      {Map<String, dynamic>? body, bool useAuth = false}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(useAuth: useAuth);
    return http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(String endpoint,
      {Map<String, dynamic>? body, bool useAuth = false}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(useAuth: useAuth);
    return http.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String endpoint, {bool useAuth = false}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(useAuth: useAuth);
    return http.delete(uri, headers: headers);
  }
}
