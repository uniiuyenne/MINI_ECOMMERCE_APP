import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_smart_image.dart';

class PurchaseHistoryScreen extends StatelessWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử mua hàng')),
      body: Builder(
        builder: (context) {
          if (!orderProvider.hasActiveUser) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Vui lòng đăng nhập để xem lịch sử mua hàng đã lưu trên cơ sở dữ liệu.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.error != null && orderProvider.orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      orderProvider.error!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<OrderProvider>().reload(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          final orders = orderProvider.receivedHistory;
          if (orders.isEmpty) {
            return const Center(
              child: Text('Chưa có đơn nào được xác nhận đã nhận hàng.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final effectiveStatus = orderProvider.statusOf(order);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Đơn hàng #${order.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              effectiveStatus,
                              style: const TextStyle(
                                color: Color(0xFFE65100),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Thời gian: ${Formatters.dateTime(order.createdAt)}'),
                      Text('Địa chỉ nhận hàng: ${order.address}'),
                      if (order.phoneNumber.isNotEmpty)
                        Text('Số điện thoại: ${order.phoneNumber}'),
                      Text('Thanh toán: ${order.paymentMethod}'),
                      const Divider(height: 24),
                      ...order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: AppSmartImage(
                                  imageUrl: item.product.image,
                                  category: item.product.displayCategory,
                                  label: item.product.displayTitle,
                                  width: 56,
                                  height: 56,
                                  borderRadius: 8,
                                  iconSize: 20,
                                  fontSize: 9,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.displayTitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Phân loại: ${item.size} / ${item.color}'),
                                    Text('Số lượng: ${item.quantity}'),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                Formatters.currency(item.subtotal * 25000),
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Tổng đơn: ${Formatters.currency(order.total * 25000)}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}