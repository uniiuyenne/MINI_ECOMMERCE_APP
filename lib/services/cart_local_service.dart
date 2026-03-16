import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';

class CartLocalService {
  static const _cartKeyPrefix = 'cart_items_v1_';
  static const _legacyCartKey = 'cart_items_v1';

  Future<List<CartItem>> loadCart(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _cartKey(userId);
    var raw = prefs.getString(key);

    if ((raw == null || raw.isEmpty) && userId == null) {
      raw = prefs.getString(_legacyCartKey);
    }

    if (raw == null || raw.isEmpty) {
      return [];
    }

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCart(String? userId, List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKey(userId), raw);
  }

  String _cartKey(String? userId) => '$_cartKeyPrefix${userId ?? 'guest'}';
}
