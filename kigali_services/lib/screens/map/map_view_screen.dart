import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/listing_provider.dart';
import '../directory/listing_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ListingProvider>().listenToListings();
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _updateMarkers(List<dynamic> listings) {
    final newMarkers = <Marker>{};

    for (var listing in listings) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(listing.id),
          position: LatLng(listing.latitude, listing.longitude),
          infoWindow: InfoWindow(
            title: listing.name,
            snippet: listing.address,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListingDetailScreen(listing: listing),
                ),
              );
            },
          ),
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListingProvider>();

    if (provider.isDirectoryLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Map View'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.directoryError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Map View'), centerTitle: true),
        body: Center(child: Text('Error: ${provider.directoryError}')),
      );
    }

    if (provider.allListings.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Map View'), centerTitle: true),
        body: const Center(child: Text('No listings to display on map')),
      );
    }

    // Update markers when listings change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMarkers(provider.allListings);
    });

    // Default camera position (center of Kigali, Rwanda)
    const CameraPosition kigaliCenter = CameraPosition(
      target: LatLng(-1.9536, 30.0588),
      zoom: 12,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Map View'), centerTitle: true),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: kigaliCenter,
        markers: _markers,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
      ),
    );
  }
}
