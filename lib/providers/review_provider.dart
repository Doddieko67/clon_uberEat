import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clonubereat/models/review_model.dart';

// Define an AsyncNotifier for managing a list of reviews
class ReviewsNotifier extends AsyncNotifier<List<Review>> {
  late final firestore.CollectionReference _reviewsCollection;

  @override
  Future<List<Review>> build() async {
    _reviewsCollection = firestore.FirebaseFirestore.instance.collection('reviews');
    // Listen to real-time updates from Firestore
    ref.onDispose(
      _reviewsCollection.snapshots().listen((snapshot) {
        state = AsyncValue.data(
          snapshot.docs
              .map((doc) => Review.fromMap(doc.data() as Map<String, dynamic>))
              .toList(),
        );
      }).cancel,
    );
    // Initial fetch
    final snapshot = await _reviewsCollection.get();
    return snapshot.docs
        .map((doc) => Review.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Add a new review
  Future<void> addReview(Review review) async {
    state = const AsyncValue.loading();
    try {
      await _reviewsCollection.doc(review.id).set(review.toMap());
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update an existing review
  Future<void> updateReview(Review review) async {
    state = const AsyncValue.loading();
    try {
      await _reviewsCollection.doc(review.id).update(review.toMap());
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Delete a review
  Future<void> deleteReview(String reviewId) async {
    state = const AsyncValue.loading();
    try {
      await _reviewsCollection.doc(reviewId).delete();
      // State will be updated by the snapshot listener
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// The provider that exposes the ReviewsNotifier
final reviewsProvider = AsyncNotifierProvider<ReviewsNotifier, List<Review>>(
  () => ReviewsNotifier(),
);
