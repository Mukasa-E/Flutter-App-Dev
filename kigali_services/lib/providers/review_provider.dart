import 'dart:async';
import 'package:flutter/material.dart';

import '../models/review.dart';
import '../services/logger_service.dart';
import '../services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  Map<String, List<Review>> _reviewsByListing = {};
  Map<String, bool> _loadingState = {};
  Map<String, String?> _errorState = {};
  Map<String, StreamSubscription<List<Review>>> _subscriptions = {};

  List<Review> getAllReviews() {
    // Flatten all reviews from all listings
    final allReviews = <Review>[];
    for (var reviews in _reviewsByListing.values) {
      allReviews.addAll(reviews);
    }
    // Sort by timestamp descending
    allReviews.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return allReviews;
  }

  List<Review> getReviewsForListing(String listingId) {
    return _reviewsByListing[listingId] ?? [];
  }

  bool isLoadingReviews(String listingId) {
    return _loadingState[listingId] ?? false;
  }

  String? getLoadError(String listingId) {
    return _errorState[listingId];
  }

  double getAverageRating(String listingId) {
    final reviews = getReviewsForListing(listingId);
    if (reviews.isEmpty) return 0.0;

    final sum = reviews.fold<double>(0, (prev, r) => prev + r.rating);
    return sum / reviews.length;
  }

  int getReviewCount(String listingId) {
    return getReviewsForListing(listingId).length;
  }

  void listenToReviews(String listingId) {
    // Cancel existing subscription if any
    _subscriptions[listingId]?.cancel();

    _loadingState[listingId] = true;
    _errorState[listingId] = null;
    notifyListeners();

    try {
      final subscription = _reviewService
          .getReviewsForListing(listingId)
          .listen(
            (reviews) {
              _reviewsByListing[listingId] = reviews;
              _loadingState[listingId] = false;
              _errorState[listingId] = null;
              LoggerService.info(
                'Loaded ${reviews.length} reviews for listing $listingId',
              );
              notifyListeners();
            },
            onError: (error) {
              _loadingState[listingId] = false;
              _errorState[listingId] = error.toString();
              LoggerService.error(
                'Error loading reviews for $listingId',
                error,
              );
              notifyListeners();
            },
          );

      _subscriptions[listingId] = subscription;
    } catch (e) {
      _loadingState[listingId] = false;
      _errorState[listingId] = e.toString();
      LoggerService.error('Exception loading reviews for $listingId', e);
      notifyListeners();
    }
  }

  Future<void> addReview(Review review) async {
    try {
      await _reviewService.addReview(review);
      LoggerService.info('Review added successfully for ${review.listingId}');
      notifyListeners();
    } catch (e) {
      LoggerService.error('Failed to add review', e);
      rethrow;
    }
  }

  Future<void> deleteReview(String listingId, String reviewId) async {
    try {
      await _reviewService.deleteReview(reviewId);
      // Remove from local list
      _reviewsByListing[listingId]?.removeWhere((r) => r.id == reviewId);
      LoggerService.info('Review deleted successfully: $reviewId');
      notifyListeners();
    } catch (e) {
      LoggerService.error('Failed to delete review', e);
      rethrow;
    }
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}
