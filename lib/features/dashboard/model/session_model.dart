class SessionModel {
  String? id;
  String? group;
  int? radius;
  String? title;
  String? location;
  String? checkin_status;
  DateTime? startTime;
  DateTime? endTime;
  String? status;
  double? latitude;
  double? longitude;

  SessionModel({
    this.id,
    this.group,
    this.radius,
    this.title,
    this.checkin_status,
    this.location,
    this.startTime,
    this.endTime,
    this.status,
    this.latitude,
    this.longitude
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['_id'],
      group: json['group'],
      title: json['title'],
      radius: json['radius'],
      location: json['building_name'],
      checkin_status: json['checkin_status'] ?? '',
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      status: json['status']
    );
  }
}
