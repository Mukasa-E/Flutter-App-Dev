import 'dart:async';
import 'package:flutter/material.dart';

import '../models/listing.dart';
import '../services/firestore_service.dart';

/// ListingProvider manages all listing-related state and operations.
///
/// This provider uses the Provider pattern to keep UI widgets separated from
/// backend Firebase operations. All CRUD operations (Create, Read, Update, Delete)
/// go through this provider, which uses FirestoreService to interact with the database.
///
/// State Management Responsibilities:
/// - Maintain lists of all listings and user's listings
/// - Track loading and error states during operations
/// - Provide filtering by category
/// - Support search by name, address, or category
/// - Expose listings to UI via getters
///
/// Data Flow:
/// User Action (UI) → ListingProvider → FirestoreService → Firestore → Stream → UI Rebuild
class ListingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  /// All listings from the directory (all users)
  List<Listing> _allListings = [];

  /// Listings created by the current user
  List<Listing> _myListings = [];

  /// Loading state indicators
  bool _isDirectoryLoading = false;
  bool _isMyListingsLoading = false;
  bool _isSavingListing = false;

  /// Filter and search state
  String _selectedCategory = 'All';
  String _searchQuery = '';

  /// Error messages from operations
  String? _directoryError;
  String? _myListingsError;
  String? _saveError;

  /// Firestore stream subscriptions (must be cancelled to prevent memory leaks)
  StreamSubscription<List<Listing>>? _allListingsSub;
  StreamSubscription<List<Listing>>? _myListingsSub;

  // Getters for UI consumption
  List<Listing> get allListings => _allListings;
  List<Listing> get myListings => _myListings;

  bool get isDirectoryLoading => _isDirectoryLoading;
  bool get isMyListingsLoading => _isMyListingsLoading;
  bool get isLoading => _isSavingListing;

  String? get directoryError => _directoryError;
  String? get myListingsError => _myListingsError;
  String? get saveError => _saveError;

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  /// Returns filtered listings based on selected category and search query.
  ///
  /// Filters are applied client-side after Firestore fetches all listings.
  /// This provides instant filtering as user types without additional reads.
  List<Listing> get filteredListings {
    return _allListings.where((listing) {
      final matchesCategory =
          _selectedCategory == 'All' || listing.category == _selectedCategory;

      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          listing.name.toLowerCase().contains(query) ||
          listing.address.toLowerCase().contains(query) ||
          listing.category.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Initiates a real-time stream of all listings from Firestore.
  ///
  /// This method should be called once per app session (typically on HomeScreen.initState).
  /// The stream continues to listen for changes and automatically notifies listeners
  /// whenever listings are added, updated, or deleted by any user.
  void listenToListings() {
    _isDirectoryLoading = true;
    _directoryError = null;
    notifyListeners();

    _allListingsSub?.cancel();
    _allListingsSub = _firestoreService.getListings().listen(
      (listings) {
        _allListings = listings;
        _isDirectoryLoading = false;
        _directoryError = null;
        notifyListeners();
      },
      onError: (error) {
        _isDirectoryLoading = false;
        _directoryError = error.toString();
        notifyListeners();
      },
    );
  }

  /// Initiates a real-time stream of listings created by the current user.
  ///
  /// This stream is typically set up in MyListingsScreen.initState() to show
  /// the user's own listings. The stream updates whenever the user creates,
  /// edits, or deletes a listing.
  ///
  /// Parameters:
  ///   uid: The Firebase UID of the currently authenticated user
  void listenToMyListings(String uid) {
    _isMyListingsLoading = true;
    _myListingsError = null;
    notifyListeners();

    _myListingsSub?.cancel();
    _myListingsSub = _firestoreService
        .getListingsByUser(uid)
        .listen(
          (listings) {
            _myListings = listings;
            _isMyListingsLoading = false;
            _myListingsError = null;
            notifyListeners();
          },
          onError: (error) {
            _isMyListingsLoading = false;
            _myListingsError = error.toString();
            notifyListeners();
          },
        );
  }

  /// Creates a new listing in Firestore.
  ///
  /// This operation:
  /// 1. Sets _isSavingListing = true (shows loading UI)
  /// 2. Calls FirestoreService.createListing()
  /// 3. Firestore automatically updates the streams via listenToListings()
  /// 4. UI rebuilds with the new listing
  ///
  /// Parameters:
  ///   listing: The Listing object to create
  ///
  /// Throws: Exception if Firestore write fails
  Future<void> addListing(Listing listing) async {
    try {
      _isSavingListing = true;
      _saveError = null;
      notifyListeners();

      await _firestoreService.createListing(listing);

      _isSavingListing = false;
      _saveError = null;
      notifyListeners();
    } catch (e) {
      _isSavingListing = false;
      _saveError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Updates an existing listing in Firestore.
  ///
  /// Only the listing creator can update their listing.
  /// Changes are reflected in real-time across all screens.
  ///
  /// Parameters:
  ///   listing: The Listing object with updated fields
  ///
  /// Throws: Exception if Firestore update fails
  Future<void> updateListing(Listing listing) async {
    try {
      _isSavingListing = true;
      _saveError = null;
      notifyListeners();

      await _firestoreService.updateListing(listing);

      _isSavingListing = false;
      _saveError = null;
      notifyListeners();
    } catch (e) {
      _isSavingListing = false;
      _saveError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Deletes a listing from Firestore.
  ///
  /// Only the listing creator can delete their listing.
  /// The listing immediately disappears from all views.
  ///
  /// Parameters:
  ///   id: The document ID of the listing to delete
  ///
  /// Throws: Exception if Firestore delete fails
  Future<void> deleteListing(String id) async {
    await _firestoreService.deleteListing(id);
  }

  /// Updates the selected category filter for the directory.
  ///
  /// When category is changed, filteredListings getter automatically recalculates
  /// and all listeners are notified, triggering UI rebuild with newly filtered results.
  ///
  /// Parameters:
  ///   value: The category to filter by, or 'All' to show all listings
  void setSelectedCategory(String value) {
    _selectedCategory = value;
    notifyListeners();
  }

  /// Updates the search query for the directory.
  ///
  /// Searches across listing name, address, and category (case-insensitive).
  /// As the user types, filteredListings automatically updates without additional queries.
  ///
  /// Parameters:
  ///   value: The search query text
  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _allListingsSub?.cancel();
    _myListingsSub?.cancel();
    super.dispose();
  }
}
