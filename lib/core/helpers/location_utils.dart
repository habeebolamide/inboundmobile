import 'package:geolocator/geolocator.dart';

Future<bool> isWithinDistance(Position current, Position target, double meters) async {
  final distance = Geolocator.distanceBetween(
    current.latitude,
    current.longitude,
    target.latitude,
    target.longitude,
  );
  return distance <= meters;
}
