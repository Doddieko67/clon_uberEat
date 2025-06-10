import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clonubereat/models/category_model.dart';

// Define an AsyncNotifier for managing a list of categories
class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  late final firestore.CollectionReference _categoriesCollection;

  @override
  Future<List<Category>> build() async {
    _categoriesCollection = firestore.FirebaseFirestore.instance.collection('categories');
    // Listen to real-time updates from Firestore
    ref.onDispose(
      _categoriesCollection.snapshots().listen((snapshot) {
        state = AsyncValue.data(
          snapshot.docs
              .map((doc) => Category.fromMap(doc.data() as Map<String, dynamic>))
              .toList(),
        );
      }).cancel,
    );
    // Initial fetch
    final snapshot = await _categoriesCollection.get();
    return snapshot.docs
        .map((doc) => Category.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Add a new category
  Future<void> addCategory(Category category) async {
    state = const AsyncValue.loading();
    try {
      await _categoriesCollection.doc(category.id).set(category.toMap());
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update an existing category
  Future<void> updateCategory(Category category) async {
    state = const AsyncValue.loading();
    try {
      await _categoriesCollection.doc(category.id).update(category.toMap());
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Delete a category
  Future<void> deleteCategory(String categoryId) async {
    state = const AsyncValue.loading();
    try {
      await _categoriesCollection.doc(categoryId).delete();
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// The provider that exposes the CategoriesNotifier
final categoriesProvider = AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
  () => CategoriesNotifier(),
);
