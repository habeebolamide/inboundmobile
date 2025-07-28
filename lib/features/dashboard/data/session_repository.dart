import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:inboundmobile/core/services/api_service.dart';
import 'package:inboundmobile/core/services/geolocation_service.dart';
import 'package:inboundmobile/features/dashboard/model/session_model.dart';

class SessionRepository {
  final _api = ApiService();
  final geolocation = GeolocationService();

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

  Future<String?> getCurrentLocation(int sessionId) async {
    Position position = await geolocation.getCurrentLocation();
    final data = {
      "sessionId":sessionId,
      "latitude":position.latitude,
      "longitude":position.longitude
    };

    final response = await _api.post('/v1/organization/sessions/checkin',body: data);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['message'];
    }else{
      // print(jsonDecode(response.body));
      throw Exception(jsonDecode(response.body)['message'] ?? 'An Error Occured');
    }
  }

}
