import 'package:flutter/material.dart';

class BookmarkProvider extends ChangeNotifier {
  final Set<String> _bookmarkedIds = {};

  bool isBookmarked(String listingId) {
    return _bookmarkedIds.contains(listingId);
  }

  List<String> get bookmarkedIds => _bookmarkedIds.toList();

  void toggleBookmark(String listingId) {
    if (_bookmarkedIds.contains(listingId)) {
      _bookmarkedIds.remove(listingId);
    } else {
      _bookmarkedIds.add(listingId);
    }
    notifyListeners();
  }
}
