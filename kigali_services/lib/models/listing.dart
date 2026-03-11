import 'package:cloud_firestore/cloud_firestore.dart';

/// Listing represents a single service or place in the Kigali directory.
///
/// Each listing contains information about a location (hospital, restaurant, etc.)
/// including its details, geographic coordinates for map display, and metadata.
///
/// Data Flow:
/// 1. Firestore stores listings in /listings collection
/// 2. FirestoreService converts Firestore documents to Listing objects via fromFirestore()
/// 3. ListingProvider streams listings to UI
/// 4. UI displays listing information and navigates to details with GoogleMaps
class Listing {
  /// Unique identifier for the listing in Firestore (auto-generated or timestamp-based)
  final String id;

  /// Name of the service/place (e.g., "Kigali Central Hospital")
  final String name;

  /// Category of the service (e.g., "Hospital", "Restaurant", "Police", "Park")
  /// Used for filtering in the directory
  final String category;

  /// Physical address of the location
  final String address;

  /// Contact number for the service/place
  final String contactNumber;

  /// Detailed description of the service/place
  final String description;

  /// Geographic latitude for map marker placement
  final double latitude;

  /// Geographic longitude for map marker placement
  final double longitude;

  /// Firebase UID of the user who created this listing
  /// Used to determine ownership (edit/delete permissions)
  final String createdBy;

  /// Server timestamp when the listing was created
  /// Used for sorting listings (most recent first)
  final Timestamp timestamp;

  Listing({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.timestamp,
  });

  /// Converts a Firestore DocumentSnapshot into a Listing object.
  ///
  /// Called by FirestoreService when reading from Firestore streams.
  /// The document ID becomes the listing ID.
  ///
  /// Parameters:
  ///   doc: Firestore DocumentSnapshot containing listing data
  ///
  /// Returns: A fully initialized Listing object
  factory Listing.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Listing(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      address: data['address'] ?? '',
      contactNumber: data['contact'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      createdBy: data['createdBy'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  /// Converts a Listing object to a Map for Firestore storage.
  ///
  /// Called by FirestoreService before writing to Firestore.
  /// Note: 'id' is not included (Firestore uses document ID for that).
  /// Note: 'contact' is used as the key (not 'contactNumber') to match Firestore schema.
  ///
  /// Returns: Map<String, dynamic> ready for Firestore write operations
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'contact': contactNumber,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'timestamp': timestamp,
    };
  }

  /// Creates a copy of this listing with selected fields optionally replaced.
  ///
  /// Used when updating a listing (e.g., changing name while keeping location).
  /// Null parameters are ignored and original values retained.
  ///
  /// Returns: A new Listing instance with updated/original values
  Listing copyWith({
    String? id,
    String? name,
    String? category,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
    String? createdBy,
    Timestamp? timestamp,
  }) {
    return Listing(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy ?? this.createdBy,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
