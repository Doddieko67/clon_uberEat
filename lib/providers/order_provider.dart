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
