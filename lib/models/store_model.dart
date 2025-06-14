import 'package:clonubereat/models/user_model.dart';
import 'package:clonubereat/models/operating_hours.dart';

class Store extends User {
  final String storeName;
  final String address;
  final String category;
  final double rating;
  final int reviewCount;
  final OperatingHours openingHours;
  final bool isOpen;
  final String? bannerUrl;
  final String? description;
  final double deliveryFee;
  final int deliveryTime;
  final String? specialOffer;
  final bool hasSpecialOffer;

  Store({
    required String id,
    required String name,
    String? phone,
    required UserStatus status,
    required DateTime lastActive,
    String? photoUrl,
    String? notes,
    required this.storeName,
    required this.address,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.openingHours,
    required this.isOpen,
    this.bannerUrl,
    this.description,
    required this.deliveryFee,
    required this.deliveryTime,
    this.specialOffer,
    this.hasSpecialOffer = false,
  }) : super(
          id: id,
          name: name,
          phone: phone,
          boletaNumber: '',
          role: UserRole.store,
          status: status,
          lastActive: lastActive,
          photoUrl: photoUrl,
          notes: notes,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'storeName': storeName,
      'address': address,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'openingHours': openingHours.toMap(),
      'isOpen': isOpen,
      'bannerUrl': bannerUrl,
      'description': description,
      'deliveryFee': deliveryFee,
      'deliveryTime': deliveryTime,
      'specialOffer': specialOffer,
      'hasSpecialOffer': hasSpecialOffer,
    };
  }

  factory Store.fromMap(Map<String, dynamic> map) {
    final userMap = User.fromMap(map);
    return Store(
      id: userMap.id,
      name: userMap.name,
      phone: userMap.phone,
      status: userMap.status,
      lastActive: userMap.lastActive,
      photoUrl: userMap.photoUrl,
      notes: userMap.notes,
      storeName: map['storeName'] as String,
      address: map['address'] as String,
      category: map['category'] as String,
      rating: (map['rating'] as num).toDouble(),
      reviewCount: map['reviewCount'] as int,
      openingHours: OperatingHours.fromMap(map['openingHours'] as Map<String, dynamic>),
      isOpen: map['isOpen'] as bool,
      bannerUrl: map['bannerUrl'] as String?,
      description: map['description'] as String?,
      deliveryFee: (map['deliveryFee'] as num).toDouble(),
      deliveryTime: map['deliveryTime'] as int,
      specialOffer: map['specialOffer'] as String?,
      hasSpecialOffer: map['hasSpecialOffer'] as bool? ?? false,
    );
  }

  Store copyWith({
    String? id,
    String? name,
    String? phone,
    String? boletaNumber,
    UserRole? role,
    UserStatus? status,
    DateTime? lastActive,
    String? photoUrl,
    String? notes,
    String? storeName,
    String? address,
    String? category,
    double? rating,
    int? reviewCount,
    OperatingHours? openingHours,
    bool? isOpen,
    String? bannerUrl,
    String? description,
    double? deliveryFee,
    int? deliveryTime,
    String? specialOffer,
    bool? hasSpecialOffer,
  }) {
    final userCopy = super.copyWith(
      id: id,
      name: name,
      phone: phone,
      boletaNumber: boletaNumber,
      role: this.role,
      status: status,
      lastActive: lastActive,
      photoUrl: photoUrl,
      notes: notes,
    );
    return Store(
      id: id ?? this.id,
      name: userCopy.name,
      phone: userCopy.phone,
      status: userCopy.status,
      lastActive: userCopy.lastActive,
      photoUrl: userCopy.photoUrl,
      notes: userCopy.notes,
      storeName: storeName ?? this.storeName,
      address: address ?? this.address,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      openingHours: openingHours ?? this.openingHours,
      isOpen: isOpen ?? this.isOpen,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      description: description ?? this.description,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      specialOffer: specialOffer ?? this.specialOffer,
      hasSpecialOffer: hasSpecialOffer ?? this.hasSpecialOffer,
    );
  }
}
