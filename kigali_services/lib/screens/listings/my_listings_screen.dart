import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/listing_card.dart';
import '../directory/add_edit_listing_screen.dart';
import '../directory/listing_detail_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        context.read<ListingProvider>().listenToMyListings(uid);
      }
    });
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Listing'),
        content: const Text('Are you sure you want to delete this listing?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<ListingProvider>().deleteListing(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Listings'), centerTitle: true),
      body: provider.isMyListingsLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.myListingsError != null
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
                      provider.myListingsError ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final uid = context.read<AuthProvider>().user?.uid;
                        if (uid != null) {
                          context.read<ListingProvider>().listenToMyListings(
                            uid,
                          );
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : provider.myListings.isEmpty
          ? const EmptyState(
              message: 'You have not created any listings yet.',
              icon: Icons.add_location_alt_outlined,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.myListings.length,
              itemBuilder: (context, index) {
                final listing = provider.myListings[index];
                return ListingCard(
                  listing: listing,
                  showActions: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListingDetailScreen(listing: listing),
                      ),
                    );
                  },
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditListingScreen(listing: listing),
                      ),
                    );
                  },
                  onDelete: () => _confirmDelete(listing.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditListingScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
