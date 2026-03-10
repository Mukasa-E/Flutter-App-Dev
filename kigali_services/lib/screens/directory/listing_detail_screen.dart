import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing.dart';
import '../../models/review.dart';
import '../../providers/review_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/auth_provider.dart';

class ListingDetailScreen extends StatelessWidget {
  final Listing listing;

  const ListingDetailScreen({
    super.key,
    required this.listing,
  });

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

  Future<void> _showRatingDialog(BuildContext context) async {
    double selectedRating = 5.0;
    final commentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rate this service'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFDB022),
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            selectedRating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'Write your review',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final authProvider = context.read<AuthProvider>();
                    final reviewProvider = context.read<ReviewProvider>();
                    
                    final review = Review(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      listingId: listing.id,
                      userName: authProvider.user?.displayName ?? 'Guest',
                      rating: selectedRating,
                      comment: commentController.text.trim(),
                      timestamp: DateTime.now(),
                    );
                    
                    reviewProvider.addReview(review);
                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Review submitted!')),
                    );
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewProvider>();
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final avgRating = reviewProvider.getAverageRating(listing.id);
    final reviewCount = reviewProvider.getReviewCount(listing.id);
    final reviews = reviewProvider.getReviewsForListing(listing.id);
    final isBookmarked = bookmarkProvider.isBookmarked(listing.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(listing.name),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? const Color(0xFFFDB022) : Colors.white,
            ),
            onPressed: () {
              bookmarkProvider.toggleBookmark(listing.id);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header with name and category
          Text(
            listing.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  listing.category,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '0.6 km',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Popular neighborhood cafe\nKnown for tasty pastries,\nand light meals in a cozy\natmosphere.',
                style: TextStyle(
                  color: Colors.grey[300],
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Rate this service button
          ElevatedButton(
            onPressed: () => _showRatingDialog(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Rate this service'),
          ),
          const SizedBox(height: 20),

          // Reviews section
          Row(
            children: [
              const Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (avgRating > 0) ...[
                Text(
                  avgRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.star,
                  color: Color(0xFFFDB022),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '$reviewCount review${reviewCount != 1 ? 's' : ''}',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Average rating display
          if (avgRating > 0) ...[
            Row(
              children: [
                Text(
                  'Av. R rating',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                return Icon(
                  i < avgRating.floor()
                      ? Icons.star
                      : (i < avgRating ? Icons.star_half : Icons.star_border),
                  color: const Color(0xFFFDB022),
                  size: 20,
                );
              }),
            ),
            const SizedBox(height: 20),
          ],

          // Review list
          ...reviews.map((review) {
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
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _getTimeAgo(review.timestamp),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.comment,
                      style: TextStyle(
                        color: Colors.grey[300],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          if (reviews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No reviews yet.\nBe the first to review!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Contact info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(listing.address)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 18),
                      const SizedBox(width: 8),
                      Text(listing.contactNumber),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}