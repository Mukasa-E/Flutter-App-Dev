import 'package:flutter/material.dart';

import '../../models/listing.dart';

class ListingDetailScreen extends StatelessWidget {
  final Listing listing;

  const ListingDetailScreen({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(listing.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            listing.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text('Category: ${listing.category}'),
          const SizedBox(height: 8),
          Text('Address: ${listing.address}'),
          const SizedBox(height: 8),
          Text('Contact: ${listing.contactNumber}'),
          const SizedBox(height: 8),
          Text('Description: ${listing.description}'),
          const SizedBox(height: 8),
          Text('Latitude: ${listing.latitude}'),
          const SizedBox(height: 8),
          Text('Longitude: ${listing.longitude}'),
          const SizedBox(height: 20),
          Container(
            height: 220,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Google Map will appear here next.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.directions),
            label: const Text('Get Directions'),
          ),
        ],
      ),
    );
  }
}