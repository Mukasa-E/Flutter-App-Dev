import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/listing.dart';
import '../../services/logger_service.dart';

class ListingDetailScreen extends StatefulWidget {
  final Listing listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  late GoogleMapController mapController;

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _launchDirections() async {
    final latitude = widget.listing.latitude;
    final longitude = widget.listing.longitude;
    final mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    try {
      if (await canLaunchUrl(Uri.parse(mapsUrl))) {
        await launchUrl(
          Uri.parse(mapsUrl),
          mode: LaunchMode.externalApplication,
        );
        LoggerService.info(
          'Launched maps for ${widget.listing.name} at $latitude, $longitude',
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch directions')),
        );
      }
    } catch (e) {
      LoggerService.error('Failed to launch directions', e);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final initialCameraPosition = CameraPosition(
      target: LatLng(listing.latitude, listing.longitude),
      zoom: 15,
    );

    return Scaffold(
      appBar: AppBar(title: Text(listing.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(listing.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          // Map
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 220,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: initialCameraPosition,
                markers: {
                  Marker(
                    markerId: MarkerId(listing.id),
                    position: LatLng(listing.latitude, listing.longitude),
                    infoWindow: InfoWindow(title: listing.name),
                  ),
                },
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Category
          _buildDetailRow('Category', listing.category),
          const SizedBox(height: 12),
          // Address
          _buildDetailRow('Address', listing.address),
          const SizedBox(height: 12),
          // Contact
          _buildDetailRow('Contact', listing.contactNumber),
          const SizedBox(height: 12),
          // Description
          Text('Description', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(listing.description),
          const SizedBox(height: 12),
          // Coordinates
          _buildDetailRow('Latitude', listing.latitude.toString()),
          const SizedBox(height: 12),
          _buildDetailRow('Longitude', listing.longitude.toString()),
          const SizedBox(height: 20),
          // Get Directions Button
          ElevatedButton.icon(
            onPressed: _launchDirections,
            icon: const Icon(Icons.directions),
            label: const Text('Get Directions'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }
}
