import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final options = DefaultFirebaseOptions.maybeCurrentPlatform;
    if (options != null) {
      await Firebase.initializeApp(options: options);

      if (kIsWeb) {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          webExperimentalAutoDetectLongPolling: false,
          webExperimentalForceLongPolling: true,
        );
      }
    }
  } catch (exception) {
    debugPrint('Firebase init warning: $exception');
  }

  runApp(const MiniECommerceApp());
}
