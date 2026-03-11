import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/listing_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_card.dart';
import '../directory/listing_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        context.read<BookmarkProvider>().initializeForUser(uid);
      }
      context.read<ListingProvider>().listenToListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = context.watch<BookmarkProvider>();
    final listingProvider = context.watch<ListingProvider>();
    final authProvider = context.read<AuthProvider>();

    // Get all listings
    final allListings = listingProvider.allListings;

    // Filter to only bookmarked listings
    final bookmarkedId = bookmarkProvider.bookmarkedIds;
    final bookmarkedListings = allListings
        .where((listing) => bookmarkedId.contains(listing.id))
        .toList();

    // Show loading if either provider is loading
    if (listingProvider.isDirectoryLoading ||
        (authProvider.user != null && bookmarkProvider.isLoading)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bookmarks'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error if there's an error
    if (listingProvider.directoryError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bookmarks'), centerTitle: true),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Unable to Load Bookmarks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(listingProvider.directoryError ?? 'Unknown error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    listingProvider.listenToListings();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show empty state if no bookmarks
    if (bookmarkedListings.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bookmarks'), centerTitle: true),
        body: const EmptyState(
          message:
              'No bookmarked listings yet.\nAdd listings from the directory!',
          icon: Icons.bookmark_border,
        ),
      );
    }

    // Show bookmarked listings
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks'), centerTitle: true),
      body: ListView.builder(
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
