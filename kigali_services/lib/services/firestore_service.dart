import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/listing.dart';
import 'logger_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _listings =>
      _firestore.collection('listings');

  Stream<List<Listing>> getListings() {
    LoggerService.firestore('READ', 'listings');
    return _listings
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          LoggerService.info('Fetched ${snapshot.docs.length} listings');
          return snapshot.docs
              .map((doc) => Listing.fromFirestore(doc))
              .toList();
        })
        .handleError((error) {
          LoggerService.firestore('READ ERROR', 'listings', '', error);
          throw error;
        });
  }

  Stream<List<Listing>> getListingsByUser(String uid) {
    LoggerService.firestore('READ USER LISTINGS', 'listings', uid);
    // Note: Firestore requires a composite index for where() + orderBy()
    // We fetch all listings and filter/sort in-memory as a workaround
    return _listings
        .snapshots()
        .map((snapshot) {
          final listings = snapshot.docs
              .map((doc) => Listing.fromFirestore(doc))
              .toList();
          // Filter by user in-memory
          final userListings = listings
              .where((listing) => listing.createdBy == uid)
              .toList();
          // Sort by timestamp descending
          userListings.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          LoggerService.info(
            'Fetched ${userListings.length} listings for user $uid',
          );
          return userListings;
        })
        .handleError((error) {
          LoggerService.error('Error reading user listings for $uid', error);
          throw error;
        });
  }

  Future<String> createListing(Listing listing) async {
    try {
      LoggerService.firestore('CREATE', 'listings', listing.name);
      final docRef = await _listings.add(listing.toMap());
      final docId = docRef.id;
      LoggerService.info(
        'Successfully created listing: ${listing.name} with ID: $docId',
      );
      return docId;
    } catch (e) {
      LoggerService.firestore('CREATE ERROR', 'listings', listing.name, e);
      rethrow;
    }
  }

  Future<void> updateListing(Listing listing) async {
    try {
      LoggerService.firestore('UPDATE', 'listings/${listing.id}', listing.name);
      await _listings.doc(listing.id).update(listing.toMap());
      LoggerService.info('Successfully updated listing: ${listing.name}');
    } catch (e) {
      LoggerService.firestore(
        'UPDATE ERROR',
        'listings/${listing.id}',
        listing.name,
        e,
      );
      rethrow;
    }
  }

  Future<void> deleteListing(String id) async {
    try {
      LoggerService.firestore('DELETE', 'listings/$id', '');
      await _listings.doc(id).delete();
      LoggerService.info('Successfully deleted listing: $id');
    } catch (e) {
      LoggerService.firestore('DELETE ERROR', 'listings/$id', '', e);
      rethrow;
    }
  }
}
