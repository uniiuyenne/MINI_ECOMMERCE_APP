import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_local_service.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._localService) {
    _loadCart();
  }

  final CartLocalService _localService;
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get uniqueItemCount => _items.length;

  bool get isAllSelected =>
      _items.isNotEmpty && _items.every((element) => element.isSelected);

  double get selectedTotal => _items
      .where((item) => item.isSelected)
      .fold(0, (total, item) => total + item.subtotal);

  List<CartItem> get selectedItems =>
      _items.where((element) => element.isSelected).toList();

  Future<void> _loadCart() async {
    final stored = await _localService.loadCart();
    _items
      ..clear()
      ..addAll(stored);
    notifyListeners();
  }

  Future<void> addToCart({
    required Product product,
    required String size,
    required String color,
    required int quantity,
  }) async {
    final key = '${product.id}_${size}_$color';
    final index = _items.indexWhere((item) => item.key == key);

    if (index >= 0) {
      final old = _items[index];
      _items[index] = old.copyWith(
        quantity: old.quantity + quantity,
        isSelected: true,
      );
    } else {
      _items.add(
        CartItem(
          product: product,
          size: size,
          color: color,
          quantity: quantity,
          isSelected: true,
        ),
      );
    }

    await _persist();
  }

  Future<void> toggleItemSelection(String key, bool selected) async {
    final index = _items.indexWhere((item) => item.key == key);
    if (index < 0) {
      return;
    }

    _items[index] = _items[index].copyWith(isSelected: selected);
    await _persist();
  }

  Future<void> toggleSelectAll(bool selected) async {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isSelected: selected);
    }
    await _persist();
  }

  Future<void> updateQuantity(String key, int quantity) async {
    final index = _items.indexWhere((item) => item.key == key);
    if (index < 0) {
      return;
    }

    _items[index] = _items[index].copyWith(quantity: quantity);
    await _persist();
  }

  Future<void> removeItem(String key) async {
    _items.removeWhere((item) => item.key == key);
    await _persist();
  }

  Future<void> _persist() async {
    await _localService.saveCart(_items);
    notifyListeners();
  }
}
