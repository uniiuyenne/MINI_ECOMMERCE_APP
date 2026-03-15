import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  String? _userId;

  String? get userId => _userId;
  bool get isSignedIn => _userId != null;

  void signInPlaceholder(String uid) {
    _userId = uid;
    notifyListeners();
  }

  void signOut() {
    _userId = null;
    notifyListeners();
  }
}
