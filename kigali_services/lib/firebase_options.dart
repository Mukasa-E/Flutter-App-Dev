import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
		show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
	static FirebaseOptions get currentPlatform {
		if (kIsWeb) {
			throw UnsupportedError(
				'DefaultFirebaseOptions have not been configured for web.',
			);
		}

		switch (defaultTargetPlatform) {
			case TargetPlatform.android:
				return android;
			default:
				throw UnsupportedError(
					'DefaultFirebaseOptions are not configured for $defaultTargetPlatform.',
				);
		}
	}

	static const FirebaseOptions android = FirebaseOptions(
		apiKey: 'AIzaSyAjTB_52Wf2hfPFMVRgoeqrOWRb4rJ23oU',
		appId: '1:813668235196:android:01ee2a1373d9bc84c61db9',
		messagingSenderId: '813668235196',
		projectId: 'kigali-service-43f09',
		storageBucket: 'kigali-service-43f09.firebasestorage.app',
	);
}
