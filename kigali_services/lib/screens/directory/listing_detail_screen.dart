import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/listing.dart';
import '../../models/review.dart';
import '../../providers/review_provider.dart';
import '../../services/logger_service.dart';

class ListingDetailScreen extends StatefulWidget {
  final Listing listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  late GoogleMapController mapController;
  final TextEditingController _reviewNameController = TextEditingController();
  final TextEditingController _reviewCommentController =
      TextEditingController();
  double _ratingValue = 5.0;

  @override
  void initState() {
    super.initState();
    // Initialize review provider for this listing
    Future.microtask(() {
      if (!mounted) return;
      if (widget.listing.id.isNotEmpty) {
        context.read<ReviewProvider>().listenToReviews(widget.listing.id);
      }
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    _reviewNameController.dispose();
    _reviewCommentController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _submitReview() async {
    if (_reviewNameController.text.isEmpty ||
        _reviewCommentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      final review = Review(
        id: '',
        listingId: widget.listing.id,
        userName: _reviewNameController.text.trim(),
        rating: _ratingValue,
        comment: _reviewCommentController.text.trim(),
        timestamp: DateTime.now(),
      );

      await context.read<ReviewProvider>().addReview(review);

      // Clear the form
      _reviewNameController.clear();
      _reviewCommentController.clear();
      _ratingValue = 5.0;

      if (!mounted) return;
      Navigator.pop(context); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review added successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding review: $e')));
    }
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Review'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _reviewNameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rating'),
                    Slider(
                      value: _ratingValue,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _ratingValue.toStringAsFixed(1),
                      onChanged: (value) =>
                          setState(() => _ratingValue = value),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < _ratingValue.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _reviewCommentController,
                  decoration: const InputDecoration(
                    labelText: 'Your Review',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _submitReview,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
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
    // Watch ReviewProvider to ensure reviews are loaded
    context.watch<ReviewProvider>();

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
          const SizedBox(height: 24),
          // Reviews Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reviews', style: Theme.of(context).textTheme.titleMedium),
              if (listing.id.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: _showAddReviewDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Review'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildReviewsSection(listing.id),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(String listingId) {
    final reviewProvider = context.watch<ReviewProvider>();
    final reviews = reviewProvider.getReviewsForListing(listingId);
    final isLoading = reviewProvider.isLoadingReviews(listingId);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade600),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('No reviews yet. Be the first to review!'),
      );
    }

    return Column(
      children: reviews
          .take(3)
          .map(
            (review) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            ...List.generate(5, (i) {
                              return Icon(
                                i < review.rating.floor()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.comment,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
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
