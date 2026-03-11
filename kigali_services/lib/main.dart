import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/listing_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/review_provider.dart';

/// Entry point of the Kigali City Services & Places Directory application.
///
/// This application demonstrates:
/// - Firebase Authentication with email verification
/// - Cloud Firestore for real-time data persistence
/// - Provider-based state management
/// - Clean architecture with service → provider → UI separation
/// - CRUD operations for listings, bookmarks, and reviews
/// - Google Maps integration for location-based services
Future<void> main() async {
  // Ensure Flutter binding is initialized before Firebase setup
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  // This connects the app to the Firestore backend and Firebase Authentication
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    /// MultiProvider setup for global state management
    /// This structure ensures all providers are accessible throughout the app
    /// without needing to pass dependencies manually between screens.
    MultiProvider(
      providers: [
        /// AuthProvider: Manages Firebase Authentication state
        /// - User sign up / login / logout
        /// - Email verification status
        /// - Current authenticated user session
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        /// ListingProvider: Manages CRUD operations for listings
        /// - Create, Read, Update, Delete locations/services
        /// - Real-time Firestore streams for automatic UI updates
        /// - Category filtering and search functionality
        /// - Manages both all listings and user-specific listings
        ChangeNotifierProvider(create: (_) => ListingProvider()),

        /// BookmarkProvider: Manages user bookmarks
        /// - Stores bookmarked listing IDs in Firestore under users/{uid}/bookmarks
        /// - Real-time sync across screens
        /// - Toggles bookmark state with optimistic UI updates
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),

        /// ReviewProvider: Manages listings reviews
        /// - Create, read reviews for each listing
        /// - Store star ratings (1-5) and user comments
        /// - Real-time stream of reviews for each listing
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
