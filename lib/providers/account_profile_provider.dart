import 'package:flutter/foundation.dart';

import '../models/account_profile.dart';

class AccountProfileProvider extends ChangeNotifier {
  AccountProfile? _profile;

  AccountProfile? get profile => _profile;

  void updateProfile(AccountProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  void clear() {
    _profile = null;
    notifyListeners();
  }
}
