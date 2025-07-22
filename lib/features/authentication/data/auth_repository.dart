import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/user_model.dart';

class AuthRepository {
  final String baseUrl = 'https://your-api.com/api';

  Future<UserModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body)['user']);
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<UserModel> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: {'name': name, 'email': email, 'password': password},
    );

    if (response.statusCode == 201) {
      return UserModel.fromJson(jsonDecode(response.body)['user']);
    } else {
      throw Exception('Failed to register');
    }
  }
}
