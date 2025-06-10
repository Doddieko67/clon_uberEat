import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clonubereat/models/menu_item_model.dart';

// Define an AsyncNotifier for managing a list of menu items
class MenuItemsNotifier extends AsyncNotifier<List<MenuItem>> {
  late final firestore.CollectionReference _menuItemsCollection;

  @override
  Future<List<MenuItem>> build() async {
    _menuItemsCollection = firestore.FirebaseFirestore.instance.collection('menuItems');
    // Listen to real-time updates from Firestore
    ref.onDispose(
      _menuItemsCollection.snapshots().listen((snapshot) {
        state = AsyncValue.data(
          snapshot.docs
              .map((doc) => MenuItem.fromMap(doc.data() as Map<String, dynamic>))
              .toList(),
        );
      }).cancel,
    );
    // Initial fetch
    final snapshot = await _menuItemsCollection.get();
    return snapshot.docs
        .map((doc) => MenuItem.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Add a new menu item
  Future<void> addMenuItem(MenuItem item) async {
    state = const AsyncValue.loading();
    try {
      await _menuItemsCollection.doc(item.id).set(item.toMap());
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update an existing menu item
  Future<void> updateMenuItem(MenuItem item) async {
    state = const AsyncValue.loading();
    try {
      await _menuItemsCollection.doc(item.id).update(item.toMap());
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Delete a menu item
  Future<void> deleteMenuItem(String itemId) async {
    state = const AsyncValue.loading();
    try {
      await _menuItemsCollection.doc(itemId).delete();
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// The provider that exposes the MenuItemsNotifier
final menuItemsProvider = AsyncNotifierProvider<MenuItemsNotifier, List<MenuItem>>(
  () => MenuItemsNotifier(),
);
