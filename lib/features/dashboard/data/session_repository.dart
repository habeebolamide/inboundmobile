import 'dart:convert';
import 'package:inboundmobile/core/services/api_service.dart';
import 'package:inboundmobile/features/dashboard/model/session_model.dart';

class SessionRepository {
  final _api = ApiService();

  Future<List<SessionModel>> fetchSessions() async {
    final response = await _api.get('/v1/organization/sessions');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => SessionModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sessions');
    }
  }

  Future<List<SessionModel>> todaySession() async {
    final response = await _api.get('/v1/organization/sessions/get_today_sessions');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      final check = data.map((json) => SessionModel.fromJson(json)).toList();
      return check;
    } else {
      throw Exception('Failed to load today\'s sessions');
    }
  }
}
