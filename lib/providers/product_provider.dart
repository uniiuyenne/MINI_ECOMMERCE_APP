import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider(this._apiService);

  final ApiService _apiService;

  final List<Product> _allProducts = [];
  final List<Product> _visibleProducts = [];
  bool _isLoading = false;
  bool _isLoadMore = false;
  String? _error;
  int _page = 0;
  static const int _pageSize = 8;

  List<Product> get products => List.unmodifiable(_visibleProducts);
  bool get isLoading => _isLoading;
  bool get isLoadMore => _isLoadMore;
  String? get error => _error;
  bool get hasMore => _visibleProducts.length < _allProducts.length;

  List<String> get categories {
    final list = _allProducts.map((e) => e.displayCategory).toSet().toList()
      ..sort((a, b) => a.compareTo(b));
    return list;
  }

  Future<void> initialLoad() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.fetchProducts();
      _allProducts
        ..clear()
        ..addAll(data);

      _visibleProducts.clear();
      _page = 0;
      _appendPage();
    } catch (_) {
      _error = 'Đã có lỗi khi tải sản phẩm.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.fetchProducts();
      _allProducts
        ..clear()
        ..addAll(data);
      _visibleProducts.clear();
      _page = 0;
      _appendPage();
    } catch (_) {
      _error = 'Không thể làm mới dữ liệu.';
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadMore || !hasMore) {
      return;
    }

    _isLoadMore = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 300));
    _appendPage();

    _isLoadMore = false;
    notifyListeners();
  }

  void _appendPage() {
    final start = _page * _pageSize;
    final end = (start + _pageSize).clamp(0, _allProducts.length);
    if (start >= _allProducts.length) {
      return;
    }
    _visibleProducts.addAll(_allProducts.sublist(start, end));
    _page++;
  }
}
