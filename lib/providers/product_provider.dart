import 'package:flutter/foundation.dart';

import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final List<Product> _products = <Product>[];

  List<Product> get products => List<Product>.unmodifiable(_products);

  void setProducts(List<Product> products) {
    _products
      ..clear()
      ..addAll(products);
    notifyListeners();
  }
}
