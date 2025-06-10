// lib/models/user_model.dart
enum UserRole { customer, store, deliverer, admin }

enum UserStatus { active, inactive, pending, banned }

class User {
  final String id;
  final String name;
  final String? phone; // Made optional
  final String boletaNumber;
  final UserRole role;
  final UserStatus status;
  final DateTime lastActive;
  final String? photoUrl;
  final String? notes;

  User({
    required this.id,
    required this.name,
    this.phone, // Made optional
    required this.boletaNumber,
    required this.role,
    required this.status,
    required this.lastActive,
    this.photoUrl,
    this.notes,
  });

  User copyWith({
    String? id,
    String? name,
    String? phone, // Made optional
    String? boletaNumber,
    UserRole? role,
    UserStatus? status,
    DateTime? lastActive,
    String? photoUrl,
    String? notes,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      boletaNumber: boletaNumber ?? this.boletaNumber,
      role: role ?? this.role,
      status: status ?? this.status,
      lastActive: lastActive ?? this.lastActive,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'boletaNumber': boletaNumber,
      'role': role.toString().split('.').last,
      'status': status.toString().split('.').last,
      'lastActive': lastActive.toIso8601String(),
      'photoUrl': photoUrl,
      'notes': notes,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      boletaNumber: map['boletaNumber'] as String,
      role: UserRole.values.firstWhere(
          (e) => e.toString().split('.').last == map['role'] as String),
      status: UserStatus.values.firstWhere(
          (e) => e.toString().split('.').last == map['status'] as String),
      lastActive: DateTime.parse(map['lastActive'] as String),
      photoUrl: map['photoUrl'] as String?,
      notes: map['notes'] as String?, 
    );
  }
}
