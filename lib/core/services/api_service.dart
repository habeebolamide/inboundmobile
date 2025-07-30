import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:inboundmobile/app/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_route/auto_route.dart';

class ApiService {
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

  Future<void> _handleUnauthorized(BuildContext? context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context != null) {
      context.router.replace(LoginRoute());
    }
  }

  Future<http.Response> _handleResponse(http.Response response, BuildContext? context) async {
    // print('Response body: ${response.body}');

    if (response.statusCode == 401) {
      await _handleUnauthorized(context);
    }

    return response;
  }

  Future<http.Response> get(String endpoint, {BuildContext? context}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    final response = await http.get(uri, headers: headers);
    return await _handleResponse(response, context);
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool useAuth = false,
    BuildContext? context,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    final response = await http.post(uri, headers: headers, body: jsonEncode(body));
    return await _handleResponse(response, context);
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool useAuth = false,
    BuildContext? context,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    final response = await http.put(uri, headers: headers, body: jsonEncode(body));
    return await _handleResponse(response, context);
  }

  Future<http.Response> delete(
    String endpoint, {
    bool useAuth = false,
    BuildContext? context,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    final response = await http.delete(uri, headers: headers);
    return await _handleResponse(response, context);
  }
}