import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/review_provider.dart';
import '../../widgets/empty_state.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  String _getTimeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    }
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();
    final allReviews = reviewProvider.getAllReviews();

    return Scaffold(
      appBar: AppBar(title: const Text('Reviews'), centerTitle: true),
      body: allReviews.isEmpty
          ? const EmptyState(
              message: 'No reviews yet',
              icon: Icons.rate_review_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allReviews.length,
              itemBuilder: (context, index) {
                final review = allReviews[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              review.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _getTimeAgo(review.timestamp),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              return Icon(
                                i < review.rating.floor()
                                    ? Icons.star
                                    : (i < review.rating
                                          ? Icons.star_half
                                          : Icons.star_border),
                                color: Colors.amber,
                                size: 18,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              review.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          review.comment,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
