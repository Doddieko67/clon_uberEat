
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
  final String storeId;
  final String? delivererId;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final String? deliveryAddress;
  final DateTime orderTime;
  final DateTime? deliveryTime;
  final int? rating;
  final String? specialInstructions;

  Order({
    required this.id,
    required this.customerId,
    required this.storeId,
    this.delivererId,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.deliveryAddress,
    required this.orderTime,
    this.deliveryTime,
    this.rating,
    this.specialInstructions,
  });

  Order copyWith({
    String? id,
    String? customerId,
    String? storeId,
    String? delivererId,
    List<OrderItem>? items,
    double? totalAmount,
    OrderStatus? status,
    String? deliveryAddress,
    DateTime? orderTime,
    DateTime? deliveryTime,
    int? rating,
    String? specialInstructions,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      storeId: storeId ?? this.storeId,
      delivererId: delivererId ?? this.delivererId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      orderTime: orderTime ?? this.orderTime,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      rating: rating ?? this.rating,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'storeId': storeId,
      'delivererId': delivererId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'deliveryAddress': deliveryAddress,
      'orderTime': orderTime.toIso8601String(),
      'deliveryTime': deliveryTime?.toIso8601String(),
      'rating': rating,
      'specialInstructions': specialInstructions,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      storeId: map['storeId'] as String,
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
    );
  }
}
