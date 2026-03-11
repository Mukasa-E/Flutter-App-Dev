import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing.dart';

class SeedData {
  static final List<Listing> sampleListings = [
    Listing(
      id: '',
      name: 'King Faisal Hospital',
      category: 'Hospital',
      address: 'Kigali, Muhima District',
      contactNumber: '+250 787 880 688',
      description:
          'Leading medical facility providing comprehensive healthcare services including emergency care, surgery, and ICU.',
      latitude: -1.9491,
      longitude: 30.0619,
      createdBy: 'admin',
      timestamp: Timestamp.now(),
    ),
    Listing(
      id: '',
      name: 'Rwanda National Police Headquarters',
      category: 'Police Station',
      address: 'Boulevard de la Révolution, Kigali',
      contactNumber: '+250 252 580 000',
      description:
          'Central police headquarters providing security services and emergency response.',
      latitude: -1.9547,
      longitude: 30.0597,
      createdBy: 'admin',
      timestamp: Timestamp.now(),
    ),
    Listing(
      id: '',
      name: 'Kigali Public Library',
      category: 'Library',
      address: 'Avenue de l\'Armée, Kigali',
      contactNumber: '+250 252 513 122',
      description:
          'Public library with extensive collection of books, digital resources, and reading rooms.',
      latitude: -1.9536,
      longitude: 30.0588,
      createdBy: 'admin',
      timestamp: Timestamp.now(),
    ),
    Listing(
      id: '',
      name: 'Umubano Restaurant',
      category: 'Restaurant',
      address: 'KG 7 Ave, Kigali',
      contactNumber: '+250 786 123 456',
      description:
          'Traditional Rwandan cuisine in a welcoming atmosphere. Try our signature dishes!',
      latitude: -1.9506,
      longitude: 30.0614,
      createdBy: 'admin',
      timestamp: Timestamp.now(),
    ),
    Listing(
      id: '',
      name: 'Bean There Coffee',
      category: 'Café',
      address: 'Kimironko, Kigali',
      contactNumber: '+250 788 456 789',
      description:
          'Specialty coffee roastery with locally sourced Rwandan beans. Great wifi for working.',
      latitude: -1.9526,
      longitude: 30.0602,
      createdBy: 'admin',
      timestamp: Timestamp.now(),
    ),
    Listing(
      id: '',
      name: 'Gishushu Park',
      category: 'Park',
      address: 'Gishushu, Kigali',
      contactNumber: '+250 252 589 456',
      description:
          'Beautiful green space perfect for jogging, picnics, and family outings.',
      latitude: -1.9420,
      longitude: 30.0450,
      createdBy: 'admin',
      timestamp: Timestamp.now(),
    ),
    Listing(
      id: '',
      name: 'Rwanda Revenue Authority',
      category: 'Utility Office',
      address: 'Boulevard de Nyabugogo, Kigali',
      contactNumber: '+250 252 582 300',
      description: 'Tax services and revenue administration for Rwanda.',
      latitude: -1.9568,
      longitude: 30.0542,
      createdBy: 'admin',
      timestamp: Timestamp.now(),
    ),
    Listing(
      id: '',
      name: 'Kigali Genocide Memorial',
      category: 'Tourist Attraction',
      address: 'Remera, Kigali',
      contactNumber: '+250 252 596 764',
      description:
          'Important historical and memorial site providing education about Rwanda\'s history.',
      latitude: -1.9456,
      longitude: 30.0789,
      createdBy: 'admin',
      timestamp: Timestamp.now(),
    ),
  ];

  static Future<void> seedDatabase(String? userId) async {
    if (userId == null) {
      throw Exception('User must be logged in to seed data');
    }

    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    for (var listing in sampleListings) {
      final newListing = listing.copyWith(createdBy: userId);
      final docRef = firestore.collection('listings').doc();
      batch.set(docRef, newListing.toMap());
    }

    await batch.commit();
  }
}
