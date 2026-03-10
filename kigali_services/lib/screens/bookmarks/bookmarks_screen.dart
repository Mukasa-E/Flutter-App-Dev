import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/bookmark_provider.dart';
import '../../providers/listing_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_card.dart';
import '../directory/listing_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final listingProvider = context.watch<ListingProvider>();

    final bookmarkedListings = listingProvider.allListings
        .where((listing) => bookmarkProvider.isBookmarked(listing.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Text('Bookmarks'),
                const SizedBox(width: 8),
                Switch(
                  value: bookmarkedListings.isNotEmpty,
                  onChanged: null,
                  activeColor: Colors.amber,
                ),
              ],
            ),
          ),
        ],
      ),
      body: bookmarkedListings.isEmpty
          ? const EmptyState(
              message: 'No bookmarks yet.\nStart adding your favorites!',
              icon: Icons.bookmark_border,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarkedListings.length,
              itemBuilder: (context, index) {
                final listing = bookmarkedListings[index];
                return ListingCard(
                  listing: listing,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListingDetailScreen(listing: listing),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
