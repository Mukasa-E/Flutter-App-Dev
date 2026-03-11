import 'package:cloud_firestore/cloud_firestore.dart';

import 'logger_service.dart';

class BookmarkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getBookmarksCollection(
    String userId,
  ) {
    return _firestore.collection('users').doc(userId).collection('bookmarks');
  }

  Stream<List<String>> getBookmarkedListings(String userId) {
    LoggerService.firestore('READ BOOKMARKS', 'users/$userId/bookmarks');
    return _getBookmarksCollection(userId)
        .snapshots()
        .map((snapshot) {
          final bookmarks = snapshot.docs
              .map((doc) => doc['listingId'] as String)
              .toList();
          LoggerService.info(
            'Loaded ${bookmarks.length} bookmarks for user $userId',
          );
          return bookmarks;
        })
        .handleError((error) {
          LoggerService.firestore(
            'READ BOOKMARKS ERROR',
            'users/$userId/bookmarks',
            '',
            error,
          );
          throw error;
        });
  }

  Future<bool> isBookmarked(String userId, String listingId) async {
    try {
      final doc = await _getBookmarksCollection(userId).doc(listingId).get();
      return doc.exists;
    } catch (e) {
      LoggerService.error('Failed to check bookmark status', e);
      return false;
    }
  }

  Future<void> addBookmark(String userId, String listingId) async {
    try {
      LoggerService.firestore(
        'ADD BOOKMARK',
        'users/$userId/bookmarks',
        listingId,
      );
      await _getBookmarksCollection(userId).doc(listingId).set({
        'listingId': listingId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      LoggerService.info(
        'Successfully bookmarked listing $listingId for user $userId',
      );
    } catch (e) {
      LoggerService.firestore(
        'ADD BOOKMARK ERROR',
        'users/$userId/bookmarks',
        listingId,
        e,
      );
      rethrow;
    }
  }

  Future<void> removeBookmark(String userId, String listingId) async {
    try {
      LoggerService.firestore(
        'REMOVE BOOKMARK',
        'users/$userId/bookmarks',
        listingId,
      );
      await _getBookmarksCollection(userId).doc(listingId).delete();
      LoggerService.info(
        'Successfully removed bookmark for listing $listingId from user $userId',
      );
    } catch (e) {
      LoggerService.firestore(
        'REMOVE BOOKMARK ERROR',
        'users/$userId/bookmarks',
        listingId,
        e,
      );
      rethrow;
    }
  }

  Future<void> toggleBookmark(
    String userId,
    String listingId,
    bool isCurrentlyBookmarked,
  ) async {
    if (isCurrentlyBookmarked) {
      await removeBookmark(userId, listingId);
    } else {
      await addBookmark(userId, listingId);
    }
  }
}
