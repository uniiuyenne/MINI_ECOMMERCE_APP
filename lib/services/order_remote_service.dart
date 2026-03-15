import '../models/order.dart';

class OrderRemoteService {
  Future<List<Order>> fetchOrders() async {
    return const <Order>[];
  }

  Future<void> submitOrder(Order order) async {}
}
