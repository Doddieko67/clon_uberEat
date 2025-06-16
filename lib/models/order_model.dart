
import 'package:clonubereat/models/order_item_model.dart';
import 'package:clonubereat/models/location_model.dart';

enum OrderStatus {
  pending,
  preparing,
  outForDelivery,
  delivered,
  cancelled,
}

class Order {
  final String id;
  final String customerId;
  final String? customerName; // Optional cached customer name
  final String storeId;
  final String? storeName; // Optional cached store name
  final LocationData? storeLocation; // Store location with coordinates
  final String? delivererId;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final LocationData? deliveryLocation; // Delivery location with coordinates
  final String? deliveryAddress; // Legacy field for backward compatibility
  final DateTime orderTime;
  final DateTime? deliveryTime;
  final int? rating;
  final String? specialInstructions;
  final bool isPriority; // Priority flag for urgent orders
  final String? paymentMethod; // Payment method used
  final String? customerPhone; // Optional cached customer phone
  final double? delivererLatitude; // Current deliverer latitude
  final double? delivererLongitude; // Current deliverer longitude
  final DateTime? lastLocationUpdate; // Last location update timestamp

  Order({
    required this.id,
    required this.customerId,
    this.customerName,
    required this.storeId,
    this.storeName,
    this.storeLocation,
    this.delivererId,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.deliveryLocation,
    this.deliveryAddress,
    required this.orderTime,
    this.deliveryTime,
    this.rating,
    this.specialInstructions,
    this.isPriority = false,
    this.paymentMethod,
    this.customerPhone,
    this.delivererLatitude,
    this.delivererLongitude,
    this.lastLocationUpdate,
  });

  Order copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? storeId,
    String? storeName,
    LocationData? storeLocation,
    String? delivererId,
    List<OrderItem>? items,
    double? totalAmount,
    OrderStatus? status,
    LocationData? deliveryLocation,
    String? deliveryAddress,
    DateTime? orderTime,
    DateTime? deliveryTime,
    int? rating,
    String? specialInstructions,
    bool? isPriority,
    String? paymentMethod,
    String? customerPhone,
    double? delivererLatitude,
    double? delivererLongitude,
    DateTime? lastLocationUpdate,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      storeLocation: storeLocation ?? this.storeLocation,
      delivererId: delivererId ?? this.delivererId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      orderTime: orderTime ?? this.orderTime,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      rating: rating ?? this.rating,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      isPriority: isPriority ?? this.isPriority,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customerPhone: customerPhone ?? this.customerPhone,
      delivererLatitude: delivererLatitude ?? this.delivererLatitude,
      delivererLongitude: delivererLongitude ?? this.delivererLongitude,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'storeId': storeId,
      'storeName': storeName,
      'storeLocation': storeLocation?.toMap(),
      'delivererId': delivererId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'deliveryLocation': deliveryLocation?.toMap(),
      'deliveryAddress': deliveryAddress ?? deliveryLocation?.displayAddress,
      'orderTime': orderTime.toIso8601String(),
      'deliveryTime': deliveryTime?.toIso8601String(),
      'rating': rating,
      'specialInstructions': specialInstructions,
      'isPriority': isPriority,
      'paymentMethod': paymentMethod,
      'customerPhone': customerPhone,
      'delivererLatitude': delivererLatitude,
      'delivererLongitude': delivererLongitude,
      'lastLocationUpdate': lastLocationUpdate?.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      customerName: map['customerName'] as String?,
      storeId: map['storeId'] as String,
      storeName: map['storeName'] as String?,
      storeLocation: _parseLocationData(map['storeLocation']),
      delivererId: map['delivererId'] as String?,
      items: (map['items'] as List<dynamic>)
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
          (e) => e.toString().split('.').last == map['status'] as String),
      deliveryLocation: _parseLocationData(map['deliveryLocation']),
      deliveryAddress: map['deliveryAddress'] as String?,
      orderTime: DateTime.parse(map['orderTime'] as String),
      deliveryTime: map['deliveryTime'] != null
          ? DateTime.parse(map['deliveryTime'] as String)
          : null,
      rating: map['rating'] as int?,
      specialInstructions: map['specialInstructions'] as String?,
      isPriority: map['isPriority'] as bool? ?? false,
      paymentMethod: map['paymentMethod'] as String?,
      customerPhone: map['customerPhone'] as String?,
      delivererLatitude: map['delivererLatitude'] as double?,
      delivererLongitude: map['delivererLongitude'] as double?,
      lastLocationUpdate: map['lastLocationUpdate'] != null
          ? DateTime.parse(map['lastLocationUpdate'] as String)
          : null,
    );
  }

  // Helper method to parse location data from different formats (backwards compatibility)
  static LocationData? _parseLocationData(dynamic locationData) {
    if (locationData == null) return null;
    
    if (locationData is Map<String, dynamic>) {
      // New format: LocationData object
      return LocationData.fromMap(locationData);
    } else if (locationData is String) {
      // Legacy format: String address - create LocationData with default coordinates
      return LocationData(
        address: locationData,
        latitude: 25.6876, // Default coordinates (Monterrey, México)
        longitude: -100.3171,
        formattedAddress: locationData,
      );
    }
    
    return null;
  }

  // Helper methods for location handling
  String get displayDeliveryAddress {
    return deliveryLocation?.displayAddress ?? deliveryAddress ?? 'Dirección no disponible';
  }

  String get shortDeliveryAddress {
    return deliveryLocation?.shortAddress ?? deliveryAddress?.split(',').first.trim() ?? 'Dirección no disponible';
  }

  String get displayStoreAddress {
    return storeLocation?.displayAddress ?? 'Ubicación de tienda';
  }

  // Calculate distance between store and delivery location
  double? get deliveryDistance {
    if (storeLocation != null && deliveryLocation != null) {
      return storeLocation!.distanceTo(deliveryLocation!);
    }
    return null;
  }

  // Get estimated delivery time based on distance (rough calculation)
  int get estimatedDeliveryMinutes {
    final distance = deliveryDistance;
    if (distance != null) {
      // Rough calculation: 1 minute per 100 meters + 10 minutes base time
      return ((distance / 100).ceil() + 10).clamp(8, 45);
    }
    return 15; // Default fallback
  }

  // Check if deliverer is close to delivery location
  bool get isDelivererNearDestination {
    if (delivererLatitude != null && 
        delivererLongitude != null && 
        deliveryLocation != null) {
      final delivererLocation = LocationData(
        address: 'Deliverer Location',
        latitude: delivererLatitude!,
        longitude: delivererLongitude!,
      );
      final distance = delivererLocation.distanceTo(deliveryLocation!);
      return distance <= 50; // Within 50 meters
    }
    return false;
  }

  // Get current deliverer location as LocationData
  LocationData? get delivererCurrentLocation {
    if (delivererLatitude != null && delivererLongitude != null) {
      return LocationData(
        address: 'Ubicación del repartidor',
        latitude: delivererLatitude!,
        longitude: delivererLongitude!,
      );
    }
    return null;
  }
}
