import 'package:geolocator/geolocator.dart';

class GeolocationService {
  // Request permission and get the current location
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permission denied forever');
    }

    // Use LocationSettings for the desired accuracy
    LocationSettings locationSettings = LocationSettings(
      accuracy:
          LocationAccuracy
              .bestForNavigation, // You can choose accuracy level (low, medium, high)
      distanceFilter:
          0, // (optional) Minimum distance (in meters) between location updates
    );

    // Get the current position with the updated settings
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    return position;
  }

  // Get the distance between two locations
  double getDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}
