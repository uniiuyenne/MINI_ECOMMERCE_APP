import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_smart_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa sản phẩm?'),
        content: const Text('Bạn có chắc muốn xóa sản phẩm này khỏi giỏ hàng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Giỏ hàng đang trống'))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: cart.items.length,
              itemBuilder: (_, index) {
                final item = cart.items[index];

                return Dismissible(
                  key: Key(item.key),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) => _confirmDelete(context),
                  onDismissed: (_) => cart.removeItem(item.key),
                  child: Card(
                    margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Checkbox(
                            value: item.isSelected,
                            onChanged: (value) {
                              cart.toggleItemSelection(item.key, value ?? false);
                            },
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AppSmartImage(
                              imageUrl: item.product.image,
                              category: item.product.displayCategory,
                              label: item.product.displayTitle,
                              width: 70,
                              height: 70,
                              borderRadius: 8,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.displayTitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Phân loại: ${item.size} / ${item.color}',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  Formatters.currency(item.product.price * 25000),
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  cart.updateQuantity(item.key, item.quantity + 1);
                                },
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                              Text('${item.quantity}'),
                              IconButton(
                                onPressed: () async {
                                  if (item.quantity > 1) {
                                    await cart.updateQuantity(item.key, item.quantity - 1);
                                  } else {
                                    final remove = await _confirmDelete(context);
                                    if (remove) {
                                      await cart.removeItem(item.key);
                                    }
                                  }
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Checkbox(
                value: cart.isAllSelected,
                onChanged: (value) => cart.toggleSelectAll(value ?? false),
              ),
              const Text('Chọn tất cả'),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Tổng thanh toán'),
                  Text(
                    Formatters.currency(cart.selectedTotal * 25000),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
