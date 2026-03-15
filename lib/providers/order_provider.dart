import 'package:flutter/foundation.dart';

import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = <Order>[];

  List<Order> get orders => List<Order>.unmodifiable(_orders);

  void addOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }
}
