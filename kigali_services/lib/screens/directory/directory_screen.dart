import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_categories.dart';
import '../../providers/listing_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_card.dart';
import 'listing_detail_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final provider = context.read<ListingProvider>();
      // Reset category filter when entering
      provider.setSelectedCategory('All');
      provider.listenToListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kigali City'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: appCategories.length - 1,
                itemBuilder: (context, index) {
                  final category = appCategories[index + 1];
                  final isSelected = provider.selectedCategory == category;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        provider.setSelectedCategory(
                          selected ? category : 'All',
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: provider.setSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Search for a service',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Near You',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: provider.isDirectoryLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.directoryError != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Unable to Load Listings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.directoryError!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                provider.listenToListings();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : provider.filteredListings.isEmpty
                  ? const EmptyState(
                      message: 'No listings found.',
                      icon: Icons.location_off,
                    )
                  : ListView.builder(
                      itemCount: provider.filteredListings.length,
                      itemBuilder: (context, index) {
                        final listing = provider.filteredListings[index];
                        return ListingCard(
                          listing: listing,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ListingDetailScreen(listing: listing),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
