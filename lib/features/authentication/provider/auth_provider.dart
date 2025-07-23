import 'package:flutter/material.dart';
import '../data/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final _repo = AuthRepository();
  // UserModel? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // UserModel? get user => _user;
  bool get isLoading => _isLoading;
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repo.login(
        email,
        password,
      );
      _isLoggedIn = true;
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }
}
