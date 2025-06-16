
import 'package:clonubereat/models/user_model.dart';
import 'package:clonubereat/models/location_model.dart';

class Customer extends User {
  final int totalOrders;
  final double totalSpent;
  final double averageRating;
  final String preferredLocation; // Legacy field for backward compatibility
  final LocationData? preferredLocationData; // New precise location with coordinates
  final List<LocationData>? savedLocations; // Multiple saved campus locations

  Customer({
    required super.id,
    required super.name,
    super.phone,
    required super.status,
    required super.lastActive,
    required super.boletaNumber,
    super.photoUrl,
    super.notes,
    required this.totalOrders,
    required this.totalSpent,
    required this.averageRating,
    required this.preferredLocation,
    this.preferredLocationData,
    this.savedLocations,
  }) : super(
          role: UserRole.customer,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'averageRating': averageRating,
      'preferredLocation': preferredLocation,
      'preferredLocationData': preferredLocationData?.toMap(),
      'savedLocations': savedLocations?.map((loc) => loc.toMap()).toList(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    final userMap = User.fromMap(map);
    return Customer(
      id: userMap.id,
      name: userMap.name,
      phone: userMap.phone,
      boletaNumber: userMap.boletaNumber,
      status: userMap.status,
      lastActive: userMap.lastActive,
      photoUrl: userMap.photoUrl,
      notes: userMap.notes,
      totalOrders: map['totalOrders'] as int,
      totalSpent: (map['totalSpent'] as num).toDouble(),
      averageRating: (map['averageRating'] as num).toDouble(),
      preferredLocation: map['preferredLocation'] as String,
      preferredLocationData: map['preferredLocationData'] != null
          ? LocationData.fromMap(map['preferredLocationData'] as Map<String, dynamic>)
          : null,
      savedLocations: map['savedLocations'] != null
          ? (map['savedLocations'] as List<dynamic>)
              .map((loc) => LocationData.fromMap(loc as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? boletaNumber,
    UserRole? role,
    UserStatus? status,
    DateTime? lastActive,
    String? photoUrl,
    String? notes,
    int? totalOrders,
    double? totalSpent,
    double? averageRating,
    String? preferredLocation,
    LocationData? preferredLocationData,
    List<LocationData>? savedLocations,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      boletaNumber: boletaNumber ?? this.boletaNumber,
      status: status ?? this.status,
      lastActive: lastActive ?? this.lastActive,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      averageRating: averageRating ?? this.averageRating,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      preferredLocationData: preferredLocationData ?? this.preferredLocationData,
      savedLocations: savedLocations ?? this.savedLocations,
    );
  }
}
