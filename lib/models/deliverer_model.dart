import 'package:clonubereat/models/user_model.dart';

class Deliverer extends User {
  final String licensePlate;
  final double averageRating;
  final int deliveriesCompleted;
  final bool isAvailable;

  Deliverer({
    required super.id,
    required super.name,
    super.phone,
    required super.status,
    required super.lastActive,
    required super.boletaNumber,
    super.photoUrl,
    super.notes,
    required this.licensePlate,
    required this.averageRating,
    required this.deliveriesCompleted,
    required this.isAvailable,
  }) : super(
          role: UserRole.deliverer,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'licensePlate': licensePlate,
      'averageRating': averageRating,
      'deliveriesCompleted': deliveriesCompleted,
      'isAvailable': isAvailable,
    };
  }

  factory Deliverer.fromMap(Map<String, dynamic> map) {
    final userMap = User.fromMap(map);
    return Deliverer(
      id: userMap.id,
      name: userMap.name,
      phone: userMap.phone,
      boletaNumber: userMap.boletaNumber,
      status: userMap.status,
      lastActive: userMap.lastActive,
      photoUrl: userMap.photoUrl,
      notes: userMap.notes,
      licensePlate: map['licensePlate'] as String,
      averageRating: (map['averageRating'] as num).toDouble(),
      deliveriesCompleted: map['deliveriesCompleted'] as int,
      isAvailable: map['isAvailable'] as bool,
    );
  }

  @override
  Deliverer copyWith({
    String? id,
    String? name,
    String? phone,
    String? boletaNumber,
    UserRole? role,
    UserStatus? status,
    DateTime? lastActive,
    String? photoUrl,
    String? notes,
  }) {

    return Deliverer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      boletaNumber: boletaNumber ?? this.boletaNumber,
      status: status ?? this.status,
      lastActive: lastActive ?? this.lastActive,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      licensePlate: this.licensePlate,
      averageRating: this.averageRating,
      deliveriesCompleted: this.deliveriesCompleted,
      isAvailable: this.isAvailable,
    );
  }
}
