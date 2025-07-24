import 'package:flutter/material.dart';
import 'package:inboundmobile/features/dashboard/data/session_repository.dart';
import 'package:inboundmobile/features/dashboard/model/session_model.dart';

class SessionProvider extends ChangeNotifier {
  final _repo = SessionRepository();
  
  List<SessionModel> _sessions = [];
  bool _isLoading = false;
  String? _error;

  List<SessionModel> get sessions => _sessions;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> fetchSessions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sessions = await _repo.fetchSessions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> todaySession() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sessions = await _repo.todaySession();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
