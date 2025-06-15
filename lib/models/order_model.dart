
import 'package:clonubereat/models/order_item_model.dart';

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
  final String? storeLocation; // Optional store location
  final String? delivererId;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final String? deliveryAddress;
  final DateTime orderTime;
  final DateTime? deliveryTime;
  final int? rating;
  final String? specialInstructions;
  final bool isPriority; // Priority flag for urgent orders
  final String? paymentMethod; // Payment method used
  final String? customerPhone; // Optional cached customer phone

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
    this.deliveryAddress,
    required this.orderTime,
    this.deliveryTime,
    this.rating,
    this.specialInstructions,
    this.isPriority = false,
    this.paymentMethod,
    this.customerPhone,
  });

  Order copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? storeId,
    String? storeName,
    String? storeLocation,
    String? delivererId,
    List<OrderItem>? items,
    double? totalAmount,
    OrderStatus? status,
    String? deliveryAddress,
    DateTime? orderTime,
    DateTime? deliveryTime,
    int? rating,
    String? specialInstructions,
    bool? isPriority,
    String? paymentMethod,
    String? customerPhone,
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
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      orderTime: orderTime ?? this.orderTime,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      rating: rating ?? this.rating,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      isPriority: isPriority ?? this.isPriority,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customerPhone: customerPhone ?? this.customerPhone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'storeId': storeId,
      'storeName': storeName,
      'storeLocation': storeLocation,
      'delivererId': delivererId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'deliveryAddress': deliveryAddress,
      'orderTime': orderTime.toIso8601String(),
      'deliveryTime': deliveryTime?.toIso8601String(),
      'rating': rating,
      'specialInstructions': specialInstructions,
      'isPriority': isPriority,
      'paymentMethod': paymentMethod,
      'customerPhone': customerPhone,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      customerName: map['customerName'] as String?,
      storeId: map['storeId'] as String,
      storeName: map['storeName'] as String?,
      storeLocation: map['storeLocation'] as String?,
      delivererId: map['delivererId'] as String?,
      items: (map['items'] as List<dynamic>)
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
          (e) => e.toString().split('.').last == map['status'] as String),
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
    );
  }
}
