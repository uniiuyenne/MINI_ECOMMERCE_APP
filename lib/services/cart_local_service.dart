import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';

class CartLocalService {
  static const _cartKey = 'cart_items_v1_guest';

  Future<List<CartItem>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cartKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKey, raw);
  }
}
