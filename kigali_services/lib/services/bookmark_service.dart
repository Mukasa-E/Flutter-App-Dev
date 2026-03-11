import 'package:cloud_firestore/cloud_firestore.dart';

import 'logger_service.dart';

/// BookmarkService handles all bookmark operations in Firestore.
///
/// Bookmarks are stored in a hierarchical structure for security:
/// `/users/{userId}/bookmarks/{listingId}`
///
/// Benefits of this structure:
/// - Security: Users can only access their own bookmarks (via Firestore rules)
/// - Performance: Queries are scoped to individual users
/// - Privacy: Bookmark data is isolated per user
///
/// Data Format:
/// ```
/// /users/{userId}/bookmarks/{listingId}
///   ├─ listingId (string: foreign key to /listings/{id})
///   └─ timestamp (Timestamp: when bookmark was created)
/// ```
class BookmarkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Gets the bookmarks subcollection reference for a specific user.
  ///
  /// This creates a scoped reference to user-specific data in Firestore.
  /// The subcollection path is: /users/{userId}/bookmarks
  CollectionReference<Map<String, dynamic>> _getBookmarksCollection(
    String userId,
  ) {
    return _firestore.collection('users').doc(userId).collection('bookmarks');
  }

  /// Retrieves all bookmarked listing IDs for a user as a real-time stream.
  ///
  /// The stream automatically updates when bookmarks are added or removed.
  /// This allows the UI to reflect bookmark changes across all screens
  /// without manual refresh.
  Stream<List<String>> getBookmarkedListings(String userId) {
    LoggerService.firestore('READ BOOKMARKS', 'users/$userId/bookmarks');
    LoggerService.debug('Setting up bookmark stream for user: $userId');
    return _getBookmarksCollection(userId)
        .snapshots()
        .map((snapshot) {
          final bookmarks = snapshot.docs
              .map((doc) {
                final listingId = doc['listingId'] as String?;
                LoggerService.debug(
                  'Loaded bookmark doc: ${doc.id} with listingId: $listingId',
                );
                return listingId ?? '';
              })
              .where((id) => id.isNotEmpty)
              .toList();
          LoggerService.info(
            'Loaded ${bookmarks.length} bookmarks for user $userId: $bookmarks',
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
          LoggerService.error(
            'Failed to read bookmarks for user $userId: $error',
            error,
          );
          throw error;
        });
  }

  /// Checks if a user has already bookmarked a specific listing.
  Future<bool> isBookmarked(String userId, String listingId) async {
    try {
      final doc = await _getBookmarksCollection(userId).doc(listingId).get();
      LoggerService.debug(
        'Checked bookmark status for $listingId: ${doc.exists}',
      );
      return doc.exists;
    } catch (e) {
      LoggerService.error('Failed to check bookmark status', e);
      return false;
    }
  }

  /// Adds a bookmark for a listing to the user's bookmarks collection.
  ///
  /// Creates a document at: /users/{userId}/bookmarks/{listingId}
  /// The listing ID becomes the document ID for quick lookups.
  Future<void> addBookmark(String userId, String listingId) async {
    try {
      LoggerService.firestore(
        'ADD BOOKMARK',
        'users/$userId/bookmarks',
        listingId,
      );
      LoggerService.debug(
        'Adding bookmark for user: $userId, listing: $listingId',
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
      LoggerService.error(
        'Failed to add bookmark for listing $listingId: $e',
        e,
      );
      rethrow;
    }
  }

  /// Removes a bookmark for a listing from the user's bookmarks collection.
  ///
  /// Deletes the document at: /users/{userId}/bookmarks/{listingId}
  Future<void> removeBookmark(String userId, String listingId) async {
    try {
      LoggerService.firestore(
        'REMOVE BOOKMARK',
        'users/$userId/bookmarks',
        listingId,
      );
      LoggerService.debug(
        'Removing bookmark for user: $userId, listing: $listingId',
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
      LoggerService.error(
        'Failed to remove bookmark for listing $listingId: $e',
        e,
      );
      rethrow;
    }
  }

  /// Toggles the bookmark status for a listing.
  ///
  /// If the listing is already bookmarked, it removes the bookmark.
  /// If not bookmarked, it adds a new bookmark.
  Future<void> toggleBookmark(
    String userId,
    String listingId,
    bool isCurrentlyBookmarked,
  ) async {
    LoggerService.debug(
      'Toggling bookmark for user: $userId, listing: $listingId, currently bookmarked: $isCurrentlyBookmarked',
    );
    if (isCurrentlyBookmarked) {
      await removeBookmark(userId, listingId);
    } else {
      await addBookmark(userId, listingId);
    }
  }
}
