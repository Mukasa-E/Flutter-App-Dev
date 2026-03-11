# Kigali Services

A Flutter application that connects users with local services in Kigali through a comprehensive directory, real-time bookmarking, and community reviews.

## Features

### Core Functionality
- **Service Directory** - Browse and search for local services across different categories
- **Real-time Listings** - Create, edit, and delete service listings with instant sync to cloud
- **Search & Filter** - Filter by category and search by service name
- **Google Maps Integration** - View service locations on an interactive map and get navigation directions
- **Bookmarks** - Save favorite services for quick access (cloud-synced)
- **Reviews & Ratings** - Leave and view community reviews for each service
- **User Authentication** - Secure signup and login with email verification
- **My Listings** - Manage your own service listings
- **Settings & Preferences** - User account management and app settings

## Tech Stack

**Framework**: Flutter with Null Safety
**State Management**: Provider 6.1.5+1 - Clean separation of services, providers, and UI widgets
**Backend**: Firebase
  - Authentication (Email/Password with verification)
  - Cloud Firestore (Real-time database)
  - Security Rules (User-scoped data access)

**Additional Libraries**:
- google_maps_flutter - Interactive maps with markers and directions
- url_launcher - Open maps for navigation directions
- intl - Date/time formatting

## Architecture

The app follows a **Service → Provider → UI** clean architecture pattern:

```
UI Widgets
    ↓
Providers (State Management)
    ↓
Services (Business Logic)
    ↓
Firebase (Data)
```

### Layers

**Services** (`lib/services/`)
- `FirestoreService` - All Firestore database operations (listings CRUD)
- `AuthService` - Firebase authentication and user management
- `BookmarkService` - Cloud-persisted bookmarks in Firestore subcollections
- `ReviewService` - Reviews CRUD operations and real-time streams
- `LoggerService` - Debug logging throughout the app

**Providers** (`lib/providers/`)
- `AuthProvider` - Authentication state (user, login/signup/logout)
- `ListingProvider` - All listings state (CRUD, search, filtering)
- `BookmarkProvider` - Bookmarks state with real-time updates
- `ReviewProvider` - Reviews management

**Models** (`lib/models/`)
- `Listing` - Service listing model with Firestore serialization
- `Review` - Review model with ratings
- `User` - User profile model

**Screens** (`lib/screens/`)
- `DirectoryScreen` - Browse all services
- `BookmarksScreen` - View saved services
- `ReviewsScreen` - Community reviews
- `MyListingsScreen` - Manage own listings
- `SettingsScreen` - User account and preferences

## Project Structure

```
lib/
├── main.dart                 # App entry, Firebase init, Provider setup
├── app.dart                  # App routing and theme
├── core/                     # Constants and configuration
├── models/                   # Data models (Listing, Review, User)
├── providers/                # State management (Provider pattern)
├── services/                 # Business logic & Firebase operations
├── screens/                  # UI screens
│   ├── auth/                 # Login/signup screens
│   ├── directory/            # Service listing screens
│   ├── bookmarks/
│   ├── reviews/
│   ├── my_listings/
│   ├── settings/
│   └── debug/                # Debug tools
└── widgets/                  # Reusable components
```

## Setup & Installation

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK
- Android Studio or Xcode (for iOS)
- Firebase project

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Mukasa-E/Flutter-App-Dev.git
   cd kigali_services
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [firebase.google.com](https://firebase.google.com)
   - Configure Android: Place `google-services.json` in `android/app/`
   - Configure iOS: Place `GoogleService-Info.plist` in `ios/Runner/`
   - Enable Firebase Authentication (Email/Password)
   - Create Firestore database with security rules below

4. **Firestore Security Rules**
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /listings/{document=**} {
         allow read: if true;
         allow create, update, delete: if request.auth != null;
       }
       match /users/{uid}/bookmarks/{document=**} {
         allow read, write: if request.auth.uid == uid;
       }
       match /reviews/{document=**} {
         allow read: if true;
         allow create: if request.auth != null;
       }
     }
   }
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Firestore Database Schema

### Collections

**`/listings`** - All service listings
```
listingId (auto-generated timestamp)
├── title (string)
├── description (string)
├── category (string)
├── location (string)
├── phoneNumber (string)
├── imageUrl (string)
├── userId (string - listing creator)
├── createdAt (timestamp)
└── updatedAt (timestamp)
```

**`/users/{uid}/bookmarks`** - User bookmarks (subcollection)
```
{listingId}
├── title (string)
├── addedAt (timestamp)
```

**`/reviews`** - All reviews
```
reviewId (auto-generated)
├── listingId (string - reference)
├── userId (string)
├── userName (string)
├── rating (integer 1-5)
├── comment (string)
├── createdAt (timestamp)
```

## Key Implementation Details

### Real-time Updates
All data is automatically synced from Firestore streams. Changes appear instantly without manual refresh:
- `ListingProvider.listenToListings()` - Real-time listings stream
- `BookmarkProvider` - Real-time bookmark updates
- `ReviewProvider` - Real-time review stream

### State Management
The app uses Provider pattern with `MultiProvider` setup. Services handle Firebase operations; Providers expose streams and methods to UI widgets:

```dart
// Widget watches provider and rebuilds on state change
Consumer<ListingProvider>(
  builder: (context, provider, _) {
    return ListView(
      children: provider.filteredListings.map((listing) => ListingCard(listing)).toList(),
    );
  },
)
```

### Authentication Flow
1. User signs up with email/password
2. Firebase sends verification email
3. User must verify email before accessing app
4. Login required for creating listings and bookmarks
5. Logout clears local state and resets to login screen

### Filtering & Search
Search and category filters are applied client-side on all listings (in-memory) to provide instant feedback. This approach works well for 1-10k items and avoids complex Firestore composite indices.

## Development

### Testing the Seed Data
Navigate to Settings > Bookmark Debug to access test utilities:
- **Seed Data Button** - Adds 8 sample listings for testing
- **Debug Information** - View auth status, provider state, Firestore operations

### Common Issues & Solutions

**Bookmarks not persisting?**
- Verify Firestore Security Rules include user subcollection access
- Check Firebase Console for permission denied errors
- Bookmark toggling requires valid listing IDs (timestamps)

**Listings not displaying?**
- Confirm Firestore `/listings` collection has documents
- Verify user is authenticated for full CRUD
- Check network connectivity and Firebase project setup

**Maps not loading?**
- Confirm Google Maps API key is configured for Android/iOS
- Check location permissions in app settings

## File Structure Reference

- **Main app files**: `lib/main.dart`, `lib/app.dart`
- **Service layer**: `lib/services/*_service.dart`
- **State management**: `lib/providers/*_provider.dart`
- **Data models**: `lib/models/`
- **Screens**: `lib/screens/`
- **Build config**: `pubspec.yaml`, `firebase.json`
- **Android**: `android/app/google-services.json`
- **iOS**: `ios/Runner/GoogleService-Info.plist`

## Contributing

Contributions welcome! Please follow the existing architecture patterns. Any changes to the service layer or Firestore should be documented in the comments.

## License

This project is open source under the MIT License.
