import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clonubereat/models/order_model.dart';

// Define an AsyncNotifier for managing a list of orders
class OrdersNotifier extends AsyncNotifier<List<Order>> {
  late final firestore.CollectionReference _ordersCollection;

  @override
  Future<List<Order>> build() async {
    _ordersCollection = firestore.FirebaseFirestore.instance.collection('orders');
    // Listen to real-time updates from Firestore
    ref.onDispose(
      _ordersCollection.snapshots().listen((snapshot) {
        state = AsyncValue.data(
          snapshot.docs
              .map((doc) => Order.fromMap(doc.data() as Map<String, dynamic>))
              .toList(),
        );
      }).cancel,
    );
    // Initial fetch
    final snapshot = await _ordersCollection.get();
    return snapshot.docs
        .map((doc) => Order.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Add a new order
  Future<void> addOrder(Order order) async {
    state = const AsyncValue.loading();
    try {
      await _ordersCollection.doc(order.id).set(order.toMap());
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update an existing order
  Future<void> updateOrder(Order order) async {
    state = const AsyncValue.loading();
    try {
      await _ordersCollection.doc(order.id).update(order.toMap());
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Check if an order can be cancelled
  bool canCancelOrder(Order order) {
    // Solo se puede cancelar si está pendiente o preparando
    if (order.status == OrderStatus.delivered || order.status == OrderStatus.cancelled) {
      return false;
    }
    
    // Solo se puede cancelar dentro de los primeros 10 minutos
    final timeDifference = DateTime.now().difference(order.orderTime);
    return timeDifference.inMinutes <= 10;
  }

  // Cancel an order
  Future<void> cancelOrder(String orderId, {String? cancelReason}) async {
    state = const AsyncValue.loading();
    try {
      await _ordersCollection.doc(orderId).update({
        'status': OrderStatus.cancelled.toString().split('.').last,
        'cancelReason': cancelReason ?? 'Cancelado por el usuario',
        'cancelledAt': DateTime.now().toIso8601String(),
      });
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update order rating
  Future<void> updateOrderRating(String orderId, int rating) async {
    state = const AsyncValue.loading();
    try {
      await _ordersCollection.doc(orderId).update({
        'rating': rating,
      });
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Delete an order
  Future<void> deleteOrder(String orderId) async {
    state = const AsyncValue.loading();
    try {
      await _ordersCollection.doc(orderId).delete();
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// The provider that exposes the OrdersNotifier
final ordersProvider = AsyncNotifierProvider<OrdersNotifier, List<Order>>(
  () => OrdersNotifier(),
);
