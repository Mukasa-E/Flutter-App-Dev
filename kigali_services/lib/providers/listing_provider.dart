import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../services/firestore_service.dart';

class ListingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Listing> _allListings = [];
  List<Listing> _myListings = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _error;

  List<Listing> get allListings => _allListings;
  List<Listing> get myListings => _myListings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<Listing> get filteredListings {
    return _allListings.where((listing) {
      final matchesSearch =
          listing.name.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'All' || listing.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> loadAllListings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allListings = await _firestoreService.getAllListings();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMyListings(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      _myListings = await _firestoreService.getListingsByUser(uid);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addListing(Listing listing, String currentUserId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.addListing(listing);
      await loadAllListings();
      await loadMyListings(currentUserId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateListing(Listing listing, String currentUserId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.updateListing(listing);
      await loadAllListings();
      await loadMyListings(currentUserId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteListing(String id, String currentUserId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.deleteListing(id);
      await loadAllListings();
      await loadMyListings(currentUserId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setSelectedCategory(String value) {
    _selectedCategory = value;
    notifyListeners();
  }
}