import 'dart:async';
import 'package:flutter/material.dart';

import '../models/listing.dart';
import '../services/firestore_service.dart';

class ListingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Listing> _allListings = [];
  List<Listing> _myListings = [];

  bool _isDirectoryLoading = false;
  bool _isMyListingsLoading = false;
  bool _isSavingListing = false;

  String _selectedCategory = 'All';
  String _searchQuery = '';

  String? _directoryError;
  String? _myListingsError;
  String? _saveError;

  StreamSubscription<List<Listing>>? _allListingsSub;
  StreamSubscription<List<Listing>>? _myListingsSub;

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

  Future<void> deleteListing(String id) async {
    await _firestoreService.deleteListing(id);
  }

  void setSelectedCategory(String value) {
    _selectedCategory = value;
    notifyListeners();
  }

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
