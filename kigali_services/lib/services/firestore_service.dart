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
    return _listings
        .where('createdBy', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          LoggerService.info(
            'Fetched ${snapshot.docs.length} listings for user $uid',
          );
          return snapshot.docs
              .map((doc) => Listing.fromFirestore(doc))
              .toList();
        })
        .handleError((error) {
          LoggerService.firestore(
            'READ USER LISTINGS ERROR',
            'listings',
            uid,
            error,
          );
          throw error;
        });
  }

  Future<void> createListing(Listing listing) async {
    try {
      LoggerService.firestore('CREATE', 'listings', listing.name);
      await _listings.add(listing.toMap());
      LoggerService.info('Successfully created listing: ${listing.name}');
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
