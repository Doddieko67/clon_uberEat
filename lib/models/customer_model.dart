
import 'package:clonubereat/models/user_model.dart';

class Customer extends User {
  final int totalOrders;
  final double totalSpent;
  final double averageRating;
  final String preferredLocation;

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
    );
  }
}
