import '../models/cart_item.dart';

class CartLocalService {
  Future<List<CartItem>> loadCart() async {
    return const <CartItem>[];
  }

  Future<void> saveCart(List<CartItem> items) async {}
}
