import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review.dart';
import 'logger_service.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _firestore.collection('reviews');

  Stream<List<Review>> getReviewsForListing(String listingId) {
    LoggerService.firestore('READ REVIEWS', 'reviews/$listingId');
    // Note: Firestore requires a composite index for where() + orderBy()
    // We fetch all reviews and filter/sort in-memory as a workaround
    return _reviews
        .snapshots()
        .map((snapshot) {
          final reviews = snapshot.docs
              .map((doc) => Review.fromMap(doc.data(), doc.id))
              .toList();
          // Filter by listing in-memory
          final listingReviews = reviews
              .where((review) => review.listingId == listingId)
              .toList();
          // Sort by timestamp descending
          listingReviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          LoggerService.info(
            'Fetched ${listingReviews.length} reviews for listing $listingId',
          );
          return listingReviews;
        })
        .handleError((error) {
          LoggerService.error('Error reading reviews for $listingId', error);
          throw error;
        });
  }

  Future<void> addReview(Review review) async {
    try {
      LoggerService.firestore('CREATE REVIEW', 'reviews', review.listingId);
      await _reviews.add(review.toMap());
      LoggerService.info('Successfully added review for ${review.listingId}');
    } catch (e) {
      LoggerService.firestore(
        'CREATE REVIEW ERROR',
        'reviews',
        review.listingId,
        e,
      );
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      LoggerService.firestore('DELETE REVIEW', 'reviews/$reviewId', '');
      await _reviews.doc(reviewId).delete();
      LoggerService.info('Successfully deleted review: $reviewId');
    } catch (e) {
      LoggerService.firestore(
        'DELETE REVIEW ERROR',
        'reviews/$reviewId',
        '',
        e,
      );
      rethrow;
    }
  }

  Future<double> getAverageRating(String listingId) async {
    try {
      final snapshot = await _reviews
          .where('listingId', isEqualTo: listingId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      double sum = 0;
      for (var doc in snapshot.docs) {
        sum += (doc['rating'] as num?)?.toDouble() ?? 0;
      }
      final average = sum / snapshot.docs.length;
      LoggerService.info('Average rating for $listingId: $average');
      return average;
    } catch (e) {
      LoggerService.error('Failed to calculate average rating', e);
      return 0.0;
    }
  }

  Future<int> getReviewCount(String listingId) async {
    try {
      final snapshot = await _reviews
          .where('listingId', isEqualTo: listingId)
          .count()
          .get();

      LoggerService.info('Review count for $listingId: ${snapshot.count}');
      return snapshot.count ?? 0;
    } catch (e) {
      LoggerService.error('Failed to get review count', e);
      return 0;
    }
  }
}
