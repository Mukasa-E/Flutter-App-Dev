import 'dart:async';
import 'package:flutter/material.dart';

import '../services/bookmark_service.dart';
import '../services/logger_service.dart';

class BookmarkProvider extends ChangeNotifier {
  final BookmarkService _bookmarkService = BookmarkService();

  Set<String> _bookmarkedIds = {};
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;
  StreamSubscription<List<String>>? _bookmarkSubscription;

  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isBookmarked(String listingId) {
    return _bookmarkedIds.contains(listingId);
  }

  List<String> get bookmarkedIds => _bookmarkedIds.toList();

  void initializeForUser(String userId) {
    _currentUserId = userId;
    listenToBookmarks(userId);
  }

  void listenToBookmarks(String userId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _bookmarkSubscription?.cancel();
    _bookmarkSubscription = _bookmarkService
        .getBookmarkedListings(userId)
        .listen(
          (bookmarks) {
            _bookmarkedIds = Set.from(bookmarks);
            _isLoading = false;
            _error = null;
            LoggerService.info('Loaded bookmarks for user $userId');
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            _error = error.toString();
            LoggerService.error('Error loading bookmarks', error);
            notifyListeners();
          },
        );
  }

  Future<void> toggleBookmark(String listingId) async {
    if (_currentUserId == null) {
      _error = 'User not authenticated';
      LoggerService.error('Cannot toggle bookmark: user not authenticated');
      notifyListeners();
      return;
    }

    if (listingId.isEmpty) {
      _error = 'Invalid listing ID - cannot bookmark';
      LoggerService.error('Cannot toggle bookmark: listing ID is empty');
      notifyListeners();
      return;
    }

    try {
      final isCurrentlyBookmarked = isBookmarked(listingId);

      // Optimistically update UI
      if (isCurrentlyBookmarked) {
        _bookmarkedIds.remove(listingId);
      } else {
        _bookmarkedIds.add(listingId);
      }
      _error = null;
      notifyListeners();

      // Update in Firestore
      await _bookmarkService.toggleBookmark(
        _currentUserId!,
        listingId,
        isCurrentlyBookmarked,
      );
      LoggerService.info('Toggled bookmark for listing $listingId');
    } catch (e) {
      // Revert optimistic update on error
      final isCurrentlyBookmarked = isBookmarked(listingId);
      if (isCurrentlyBookmarked) {
        _bookmarkedIds.remove(listingId);
      } else {
        _bookmarkedIds.add(listingId);
      }
      _error = 'Failed to bookmark: ${e.toString()}';
      LoggerService.error('Failed to toggle bookmark', e);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _bookmarkSubscription?.cancel();
    super.dispose();
  }
}
