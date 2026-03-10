import '../models/listing.dart';

class FirestoreService {
  final List<Listing> _storage = [
    Listing(
      id: '1',
      name: 'Kigali Central Hospital',
      category: 'Hospital',
      address: 'KG 7 Ave, Kigali',
      contactNumber: '+250788000001',
      description: 'A major public hospital in Kigali.',
      latitude: -1.9441,
      longitude: 30.0619,
      createdBy: 'demo_uid_001',
      timestamp: DateTime.now(),
    ),
    Listing(
      id: '2',
      name: 'Kigali Public Library',
      category: 'Library',
      address: 'KN 3 Rd, Kigali',
      contactNumber: '+250788000002',
      description: 'A quiet public library with study spaces.',
      latitude: -1.9500,
      longitude: 30.0588,
      createdBy: 'demo_uid_002',
      timestamp: DateTime.now(),
    ),
    Listing(
      id: '3',
      name: 'Nyandungu Park',
      category: 'Park',
      address: 'Kigali, Rwanda',
      contactNumber: '+250788000003',
      description: 'A scenic urban eco-park in Kigali.',
      latitude: -1.9294,
      longitude: 30.1056,
      createdBy: 'demo_uid_001',
      timestamp: DateTime.now(),
    ),
  ];

  Future<List<Listing>> getAllListings() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_storage);
  }

  Future<List<Listing>> getListingsByUser(String uid) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _storage.where((item) => item.createdBy == uid).toList();
  }

  Future<void> addListing(Listing listing) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _storage.add(listing);
  }

  Future<void> updateListing(Listing updatedListing) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _storage.indexWhere((item) => item.id == updatedListing.id);
    if (index != -1) {
      _storage[index] = updatedListing;
    }
  }

  Future<void> deleteListing(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _storage.removeWhere((item) => item.id == id);
  }
}