import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/listing_provider.dart';
import '../../services/logger_service.dart';

class BookmarkDebugScreen extends StatefulWidget {
  const BookmarkDebugScreen({super.key});

  @override
  State<BookmarkDebugScreen> createState() => _BookmarkDebugScreenState();
}

class _BookmarkDebugScreenState extends State<BookmarkDebugScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final listingProvider = context.watch<ListingProvider>();

    final uid = authProvider.user?.uid ?? 'No UID';
    final bookmarkedIds = bookmarkProvider.bookmarkedIds;
    final allListings = listingProvider.allListings;

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmark Debug')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Text(
              'User ID: $uid',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Provider States
            Text(
              'Auth Status: ${authProvider.isLoggedIn ? "Authenticated" : "Not Authenticated"}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              'Bookmark Provider Loading: ${bookmarkProvider.isLoading}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            if (bookmarkProvider.error != null)
              Text(
                'Bookmark Error: ${bookmarkProvider.error}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 16),

            // Bookmarked IDs
            Text(
              'Bookmarked IDs (${bookmarkedIds.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: bookmarkedIds.isEmpty
                  ? const Text('No bookmarks')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: bookmarkedIds
                          .map((id) => Text('- $id'))
                          .toList(),
                    ),
            ),
            const SizedBox(height: 16),

            // All Listings
            Text(
              'All Listings (${allListings.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: allListings.isEmpty
                  ? const Text('No listings')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: allListings
                          .take(5)
                          .map(
                            (listing) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${listing.name} (${listing.id})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Bookmarked: ${bookmarkedIds.contains(listing.id) ? "Yes" : "No"}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: bookmarkedIds.contains(listing.id)
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 24),

            // Test Button
            if (allListings.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  final testListing = allListings.first;
                  LoggerService.info(
                    'Testing bookmark toggle for: ${testListing.id}',
                  );
                  bookmarkProvider.toggleBookmark(testListing.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Toggled bookmark for ${testListing.name}. Check Firestore.',
                      ),
                    ),
                  );
                },
                child: const Text('Test Bookmark Toggle (First Listing)'),
              ),
          ],
        ),
      ),
    );
  }
}
