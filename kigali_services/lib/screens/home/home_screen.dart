import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../directory/directory_screen.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../reviews/reviews_screen.dart';
import '../listings/my_listings_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize providers with user data
    Future.microtask(() {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      final uid = authProvider.user?.uid;
      if (uid != null) {
        // Ensure BookmarkProvider is initialized with current user
        context.read<BookmarkProvider>().initializeForUser(uid);
      }
    });
  }

  final List<Widget> _pages = const [
    DirectoryScreen(),
    BookmarksScreen(),
    ReviewsScreen(),
    MyListingsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (value) {
          setState(() => _currentIndex = value);
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Services'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmarks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rate_review),
            label: 'Reviews',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared),
            label: 'My Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
