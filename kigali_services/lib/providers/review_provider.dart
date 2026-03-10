import 'package:flutter/material.dart';
import '../models/review.dart';

class ReviewProvider extends ChangeNotifier {
  final List<Review> _reviews = [
    Review(
      id: '1',
      listingId: '1',
      userName: 'Eric',
      rating: 5.0,
      comment: 'Fave grille spot to get nik done\nGreat coffee and friendly staff.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Review(
      id: '2',
      listingId: '1',
      userName: 'Sarah',
      rating: 4.5,
      comment: 'Relaxing atmosphere, tasty drinks, and good wifi.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  List<Review> get allReviews => List.from(_reviews)
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  List<Review> getReviewsForListing(String listingId) {
    return _reviews.where((r) => r.listingId == listingId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  double getAverageRating(String listingId) {
    final listingReviews = getReviewsForListing(listingId);
    if (listingReviews.isEmpty) return 0.0;
    
    final sum = listingReviews.fold<double>(0, (prev, r) => prev + r.rating);
    return sum / listingReviews.length;
  }

  int getReviewCount(String listingId) {
    return getReviewsForListing(listingId).length;
  }

  Future<void> addReview(Review review) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _reviews.add(review);
    notifyListeners();
  }
}
