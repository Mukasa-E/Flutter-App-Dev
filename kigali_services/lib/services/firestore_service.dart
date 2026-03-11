import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/listing.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _listings =>
      _firestore.collection('listings');

  Stream<List<Listing>> getListings() {
    return _listings
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList();
    });
  }

  Stream<List<Listing>> getListingsByUser(String uid) {
    return _listings
        .where('createdBy', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Listing.fromFirestore(doc)).toList();
    });
  }

  Future<void> createListing(Listing listing) async {
    await _listings.add(listing.toMap());
  }

  Future<void> updateListing(Listing listing) async {
    await _listings.doc(listing.id).update(listing.toMap());
  }

  Future<void> deleteListing(String id) async {
    await _listings.doc(id).delete();
  }
}