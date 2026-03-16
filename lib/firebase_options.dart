import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions? get maybeCurrentPlatform {
    if (kIsWeb) {
      return _isWebConfigured ? web : null;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _isAndroidConfigured ? android : null;
      case TargetPlatform.iOS:
        return _isIosConfigured ? ios : null;
      case TargetPlatform.macOS:
        return _isMacOsConfigured ? macos : null;
      case TargetPlatform.windows:
        return _isWindowsConfigured ? windows : null;
      case TargetPlatform.linux:
        return _isLinuxConfigured ? linux : null;
      default:
        return null;
    }
  }

  static bool get isConfigured => maybeCurrentPlatform != null;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA2C5MT3f1vOEKxXIt15IMgS6JrzyuFbBI',
    appId: '1:836029549309:web:6f9022d46a9e1d81d30c94',
    messagingSenderId: '836029549309',
    projectId: 'mini-ecommerce-app-32d4f',
    authDomain: 'mini-ecommerce-app-32d4f.firebaseapp.com',
    storageBucket: 'mini-ecommerce-app-32d4f.appspot.com',
    measurementId: 'G-K0BW1BBMTC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ANDROID_API_KEY',
    appId: 'REPLACE_ANDROID_APP_ID',
    messagingSenderId: 'REPLACE_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_PROJECT_ID',
    storageBucket: 'REPLACE_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_IOS_API_KEY',
    appId: 'REPLACE_IOS_APP_ID',
    messagingSenderId: 'REPLACE_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_PROJECT_ID',
    storageBucket: 'REPLACE_PROJECT_ID.appspot.com',
    iosBundleId: 'REPLACE_IOS_BUNDLE_ID',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_MACOS_API_KEY',
    appId: 'REPLACE_MACOS_APP_ID',
    messagingSenderId: 'REPLACE_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_PROJECT_ID',
    storageBucket: 'REPLACE_PROJECT_ID.appspot.com',
    iosBundleId: 'REPLACE_MACOS_BUNDLE_ID',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'REPLACE_WINDOWS_API_KEY',
    appId: 'REPLACE_WINDOWS_APP_ID',
    messagingSenderId: 'REPLACE_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_PROJECT_ID',
    authDomain: 'REPLACE_PROJECT_ID.firebaseapp.com',
    storageBucket: 'REPLACE_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'REPLACE_LINUX_API_KEY',
    appId: 'REPLACE_LINUX_APP_ID',
    messagingSenderId: 'REPLACE_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_PROJECT_ID',
    authDomain: 'REPLACE_PROJECT_ID.firebaseapp.com',
    storageBucket: 'REPLACE_PROJECT_ID.appspot.com',
  );

  static bool get _isWebConfigured => !_containsPlaceholder(web.apiKey);
  static bool get _isAndroidConfigured => !_containsPlaceholder(android.apiKey);
  static bool get _isIosConfigured => !_containsPlaceholder(ios.apiKey);
  static bool get _isMacOsConfigured => !_containsPlaceholder(macos.apiKey);
  static bool get _isWindowsConfigured => !_containsPlaceholder(windows.apiKey);
  static bool get _isLinuxConfigured => !_containsPlaceholder(linux.apiKey);

  static bool _containsPlaceholder(String value) {
    return value.startsWith('REPLACE_') || value.isEmpty;
  }
}
