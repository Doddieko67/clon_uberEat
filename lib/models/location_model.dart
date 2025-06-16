// models/location_model.dart
import 'dart:math' as math;

class LocationData {
  final String address;
  final double latitude;
  final double longitude;
  final String? placeId;
  final String? formattedAddress;
  final String? streetNumber;
  final String? route;
  final String? locality;
  final String? administrativeArea;
  final String? postalCode;
  final String? country;

  LocationData({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.placeId,
    this.formattedAddress,
    this.streetNumber,
    this.route,
    this.locality,
    this.administrativeArea,
    this.postalCode,
    this.country,
  });

  LocationData copyWith({
    String? address,
    double? latitude,
    double? longitude,
    String? placeId,
    String? formattedAddress,
    String? streetNumber,
    String? route,
    String? locality,
    String? administrativeArea,
    String? postalCode,
    String? country,
  }) {
    return LocationData(
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId ?? this.placeId,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      streetNumber: streetNumber ?? this.streetNumber,
      route: route ?? this.route,
      locality: locality ?? this.locality,
      administrativeArea: administrativeArea ?? this.administrativeArea,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'placeId': placeId,
      'formattedAddress': formattedAddress,
      'streetNumber': streetNumber,
      'route': route,
      'locality': locality,
      'administrativeArea': administrativeArea,
      'postalCode': postalCode,
      'country': country,
    };
  }

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      address: map['address'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      placeId: map['placeId'] as String?,
      formattedAddress: map['formattedAddress'] as String?,
      streetNumber: map['streetNumber'] as String?,
      route: map['route'] as String?,
      locality: map['locality'] as String?,
      administrativeArea: map['administrativeArea'] as String?,
      postalCode: map['postalCode'] as String?,
      country: map['country'] as String?,
    );
  }

  // Helper method to get display address
  String get displayAddress {
    return formattedAddress ?? address;
  }

  // Helper method to get short address
  String get shortAddress {
    if (streetNumber != null && route != null) {
      return '$streetNumber $route';
    }
    return address.split(',').first.trim();
  }

  // Helper method to calculate distance to another location
  double distanceTo(LocationData other) {
    // Simple Haversine formula implementation
    const double earthRadius = 6371000; // Earth radius in meters
    
    final double lat1Rad = latitude * (math.pi / 180);
    final double lat2Rad = other.latitude * (math.pi / 180);
    final double deltaLatRad = (other.latitude - latitude) * (math.pi / 180);
    final double deltaLngRad = (other.longitude - longitude) * (math.pi / 180);

    final double a = math.pow(math.sin(deltaLatRad / 2), 2).toDouble() +
        math.cos(lat1Rad) * math.cos(lat2Rad) * math.pow(math.sin(deltaLngRad / 2), 2);
    final double c = 2 * math.asin(math.sqrt(a));

    return earthRadius * c;
  }

  @override
  String toString() {
    return 'LocationData(address: $address, lat: $latitude, lng: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationData &&
        other.address == address &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return address.hashCode ^ latitude.hashCode ^ longitude.hashCode;
  }
}

// Helper class for tracking deliverer's real-time location
class DelivererLocationUpdate {
  final String delivererId;
  final String orderId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double? accuracy;
  final double? speed;
  final double? heading;

  DelivererLocationUpdate({
    required this.delivererId,
    required this.orderId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
    this.speed,
    this.heading,
  });

  Map<String, dynamic> toMap() {
    return {
      'delivererId': delivererId,
      'orderId': orderId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
    };
  }

  factory DelivererLocationUpdate.fromMap(Map<String, dynamic> map) {
    return DelivererLocationUpdate(
      delivererId: map['delivererId'] as String,
      orderId: map['orderId'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
      accuracy: map['accuracy'] as double?,
      speed: map['speed'] as double?,
      heading: map['heading'] as double?,
    );
  }
}