import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:kigali_services/app.dart';
import 'package:kigali_services/providers/auth_provider.dart';
import 'package:kigali_services/providers/listing_provider.dart';
import 'package:kigali_services/providers/review_provider.dart';
import 'package:kigali_services/providers/bookmark_provider.dart';

void main() {
  testWidgets('App should show login screen initially', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ListingProvider()),
          ChangeNotifierProvider(create: (_) => ReviewProvider()),
          ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that login screen elements are present
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Kigali Services Directory'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
