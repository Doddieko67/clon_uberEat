import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clonubereat/models/address_model.dart';

// Define an AsyncNotifier for managing a list of addresses
class AddressesNotifier extends AsyncNotifier<List<Address>> {
  late final firestore.CollectionReference _addressesCollection;

  @override
  Future<List<Address>> build() async {
    _addressesCollection = firestore.FirebaseFirestore.instance.collection('addresses');
    // Listen to real-time updates from Firestore
    ref.onDispose(
      _addressesCollection.snapshots().listen((snapshot) {
        state = AsyncValue.data(
          snapshot.docs
              .map((doc) => Address.fromMap(doc.data() as Map<String, dynamic>))
              .toList(),
        );
      }).cancel,
    );
    // Initial fetch
    final snapshot = await _addressesCollection.get();
    return snapshot.docs
        .map((doc) => Address.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Add a new address
  Future<void> addAddress(Address address) async {
    state = const AsyncValue.loading();
    try {
      await _addressesCollection.doc(address.id).set(address.toMap());
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update an existing address
  Future<void> updateAddress(Address address) async {
    state = const AsyncValue.loading();
    try {
      await _addressesCollection.doc(address.id).update(address.toMap());
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Delete an address
  Future<void> deleteAddress(String addressId) async {
    state = const AsyncValue.loading();
    try {
      await _addressesCollection.doc(addressId).delete();
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// The provider that exposes the AddressesNotifier
final addressesProvider = AsyncNotifierProvider<AddressesNotifier, List<Address>>(
  () => AddressesNotifier(),
);
