import 'dart:convert';
import 'package:inboundmobile/core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';

class AuthRepository {
  final _api = ApiService();
  Future<String?> login(String email, String password) async {
    final response = await 
      _api.post('/v1/auth/login',
      body: {'email': email, 'password': password}
    );
    // print('auth.login done, message: $response');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['data']['token']); // Save token
       await prefs.setString(
            'userData',
            jsonEncode(data['data']['user']),
          );
      return null;
    } else {
      // print('Login failed: ${response.body}');
      throw jsonDecode(response.body)['message'] ?? 'Login failed';
    }
  }
  
  Future<UserModel?> fetchUser() async {
    final response = await _api.get('/v1/auth/user');

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body)['user']);
    }

    return null;
  }
}
