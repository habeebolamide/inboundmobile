import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:inboundmobile/core/services/api_service.dart';
import 'package:inboundmobile/core/services/geolocation_service.dart';
import 'package:inboundmobile/features/dashboard/model/session_model.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
class SessionRepository {
  final _api = ApiService();
  final geolocation = GeolocationService();

  Future<List<SessionModel>> fetchSessions() async {
    final response = await _api.get('/v1/organization/sessions/get_sessions');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List<dynamic> sessionsData = data['data'];
      return sessionsData.map((json) => SessionModel.fromJson(json)).toList();
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

  Future<String?> getCurrentLocation(int sessionId) async {
    Position position = await geolocation.getCurrentLocation();
    // final String location = await FlutterTimezone.getLocalTimezone();
    // print("Available Timezones: $location");
    final data = {
      "sessionId":sessionId,
      "latitude":position.latitude,
      "longitude":position.longitude
    };

    final response = await _api.post('/v1/organization/sessions/checkin',body: data);
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      return null;
    }else{
      return jsonDecode(response.body)['message'] ?? 'An Error Occured';
    }
  }

  Future<String?> createSession(SessionModel session) async {
    final data = {
      'group_id': session.groupId,
      'title': session.title,
      'radius': session.radius,
      'building_name': session.location,
      'start_time': session.startTime?.toIso8601String(),
      'end_time': session.endTime?.toIso8601String(),
      'latitude': session.latitude,
      'longitude': session.longitude
    };

    try {
       final response = await _api.post('/v1/organization/sessions/supervisor_create', body: data);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
        return null;
    } catch (e) {
      print('Error creating session: $e');
      return 'An error occurred while creating the session';
      
    }
  }

  Future<List<SessionModel>> fetchSupervisorSessions() async {
    final response = await _api.get('/v1/organization/sessions/get_sessions_for_supervisors');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> sessionsData = data['data'];
      return sessionsData.map((json) => SessionModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load supervisor sessions');
    }
  }

}
