class SessionModel {
  final String title;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  SessionModel({
    required this.title,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.status
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      title: json['title'],
      location: json['building_name'] ?? '',
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      status: json['status']
    );
  }
}
