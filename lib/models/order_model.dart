
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
  final String deliveryAddress;
  final DateTime orderTime;
  final DateTime? deliveryTime;

  Order({
    required this.id,
    required this.customerId,
    required this.storeId,
    this.delivererId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.orderTime,
    this.deliveryTime,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'storeId': storeId,
      'delivererId': delivererId,
      'items': items,
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'deliveryAddress': deliveryAddress,
      'orderTime': orderTime.toIso8601String(),
      'deliveryTime': deliveryTime?.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      storeId: map['storeId'] as String,
      delivererId: map['delivererId'] as String?,
      items: List<OrderItem>.from(map['items'] as List<dynamic>),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
          (e) => e.toString().split('.').last == map['status'] as String),
      deliveryAddress: map['deliveryAddress'] as String,
      orderTime: DateTime.parse(map['orderTime'] as String),
      deliveryTime: map['deliveryTime'] != null
          ? DateTime.parse(map['deliveryTime'] as String)
          : null,
    );
  }
}
