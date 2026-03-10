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
      context.read<ListingProvider>().loadAllListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kigali City'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category chips
            SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: appCategories.length - 1, // Exclude 'All'
                itemBuilder: (context, index) {
                  final category = appCategories[index + 1];
                  final isSelected = provider.selectedCategory == category ||
                      (provider.selectedCategory == 'All' && index == 0);
                  
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
                      selectedColor: const Color(0xFFFDB022),
                      backgroundColor: const Color(0xFF132F4C),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF0A1929)
                            : Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Search bar
            TextField(
              onChanged: provider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search for a service',
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF132F4C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Near You section
            Text(
              'Near You',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            
            // Listings
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
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
                                    builder: (_) => ListingDetailScreen(
                                      listing: listing,
                                    ),
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