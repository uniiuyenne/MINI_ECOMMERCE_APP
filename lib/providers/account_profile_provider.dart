import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/account_profile.dart';

class AccountProfileProvider extends ChangeNotifier {
  AccountProfile? _profile;
  String? _activeUserKey;
  bool _isLoading = false;

  AccountProfile? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> syncProfile({
    required String userKey,
    required String displayName,
    required String email,
    required String avatarUrl,
  }) async {
    if (_activeUserKey == userKey && _profile != null) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey(userKey));

    if (raw == null) {
      _profile = AccountProfile(
        userKey: userKey,
        displayName: displayName,
        email: email,
        phoneNumber: '',
        shippingAddress: '',
        avatarUrl: avatarUrl,
        bio: '',
      );
      await prefs.setString(_prefsKey(userKey), jsonEncode(_profile!.toJson()));
    } else {
      final stored = AccountProfile.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      _profile = stored.copyWith(
        displayName: stored.displayName.isEmpty ? displayName : stored.displayName,
        email: stored.email.isEmpty ? email : stored.email,
        avatarUrl: stored.avatarUrl.isEmpty ? avatarUrl : stored.avatarUrl,
      );
    }

    _activeUserKey = userKey;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearProfile() async {
    _profile = null;
    _activeUserKey = null;
    notifyListeners();
  }

  Future<void> saveProfile({
    required String displayName,
    required String phoneNumber,
    required String shippingAddress,
    required String avatarUrl,
    required String bio,
  }) async {
    final current = _profile;
    if (current == null) {
      return;
    }

    _profile = current.copyWith(
      displayName: displayName,
      phoneNumber: phoneNumber,
      shippingAddress: shippingAddress,
      avatarUrl: avatarUrl,
      bio: bio,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey(current.userKey),
      jsonEncode(_profile!.toJson()),
    );
    notifyListeners();
  }

  String _prefsKey(String userKey) => 'account_profile_$userKey';
}
