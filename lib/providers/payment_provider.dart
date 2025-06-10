import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clonubereat/models/payment_model.dart';

// Define an AsyncNotifier for managing a list of payments
class PaymentsNotifier extends AsyncNotifier<List<Payment>> {
  late final firestore.CollectionReference _paymentsCollection;

  @override
  Future<List<Payment>> build() async {
    _paymentsCollection = firestore.FirebaseFirestore.instance.collection('payments');
    // Listen to real-time updates from Firestore
    ref.onDispose(
      _paymentsCollection.snapshots().listen((snapshot) {
        state = AsyncValue.data(
          snapshot.docs
              .map((doc) => Payment.fromMap(doc.data() as Map<String, dynamic>))
              .toList(),
        );
      }).cancel,
    );
    // Initial fetch
    final snapshot = await _paymentsCollection.get();
    return snapshot.docs
        .map((doc) => Payment.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Add a new payment
  Future<void> addPayment(Payment payment) async {
    state = const AsyncValue.loading();
    try {
      await _paymentsCollection.doc(payment.id).set(payment.toMap());
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update an existing payment
  Future<void> updatePayment(Payment payment) async {
    state = const AsyncValue.loading();
    try {
      await _paymentsCollection.doc(payment.id).update(payment.toMap());
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Delete a payment
  Future<void> deletePayment(String paymentId) async {
    state = const AsyncValue.loading();
    try {
      await _paymentsCollection.doc(paymentId).delete();
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// The provider that exposes the PaymentsNotifier
final paymentsProvider = AsyncNotifierProvider<PaymentsNotifier, List<Payment>>(
  () => PaymentsNotifier(),
);
