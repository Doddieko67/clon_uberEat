import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamController<Position>? _locationController;
  Stream<Position>? _locationStream;

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }

      final isEnabled = await isLocationServiceEnabled();
      if (!isEnabled) {
        throw Exception('Location service is disabled');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  Stream<Position> getLocationStream() {
    if (_locationStream == null) {
      _locationController = StreamController<Position>.broadcast();
      _locationStream = _locationController!.stream;
      _startLocationTracking();
    }
    return _locationStream!;
  }

  void _startLocationTracking() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) return;

      final isEnabled = await isLocationServiceEnabled();
      if (!isEnabled) return;

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      );

      Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen(
        (Position position) {
          _locationController?.add(position);
        },
        onError: (error) {
          print('Location stream error: $error');
        },
      );
    } catch (e) {
      print('Error starting location tracking: $e');
    }
  }

  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  void dispose() {
    _locationController?.close();
    _locationController = null;
    _locationStream = null;
  }
}