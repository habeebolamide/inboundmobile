class SessionModel {
  final int id;
  final String title;
  final String location;
  final String checkin_status;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  SessionModel({
    required this.id,
    required this.title,
    required this.checkin_status,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.status
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'],
      title: json['title'],
      location: json['building_name'] ,
      checkin_status: json['checkin_status'] ?? '',
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      status: json['status']
    );
  }
}
