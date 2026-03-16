import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../utils/formatters.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  static const _tabs = ['Chờ xác nhận', 'Đang giao hàng', 'Đã giao', 'Đã hủy'];

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    if (!orderProvider.hasActiveUser) {
      return Scaffold(
        appBar: AppBar(title: const Text('Đơn mua')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Vui lòng đăng nhập để xem các đơn hàng đã mua.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Đơn mua')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (orderProvider.error != null && orderProvider.orders.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Đơn mua')),
        body: Center(
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
        ),
      );
    }

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn mua'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Chờ xác nhận'),
              Tab(text: 'Đang giao hàng'),
              Tab(text: 'Đã giao'),
              Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        body: TabBarView(
          children: _tabs.map((status) {
            final orders = orderProvider.byStatus(status);
            if (orders.isEmpty) {
              return Center(child: Text('Không có đơn ở trạng thái "$status"'));
            }

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (_, index) {
                final order = orders[index];
                final effectiveStatus = orderProvider.statusOf(order);
                return Card(
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mã đơn: ${order.id}'),
                        const SizedBox(height: 4),
                        Text('Trạng thái: $effectiveStatus'),
                        Text('Thời gian: ${Formatters.dateTime(order.createdAt)}'),
                        Text('Địa chỉ: ${order.address}'),
                        if (order.phoneNumber.isNotEmpty)
                          Text('Số điện thoại: ${order.phoneNumber}'),
                        Text('Thanh toán: ${order.paymentMethod}'),
                        Text('Số sản phẩm: ${order.items.length}'),
                        const SizedBox(height: 8),
                        ...order.items.take(2).map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '• ${item.product.displayTitle} x${item.quantity}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (order.items.length > 2)
                          Text('...và ${order.items.length - 2} sản phẩm khác'),
                        const SizedBox(height: 6),
                        Text(
                          'Tổng: ${Formatters.currency(order.total * 25000)}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (effectiveStatus == 'Chờ xác nhận')
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton(
                              onPressed: () {
                                context.read<OrderProvider>().cancelOrder(order.id);
                              },
                              child: const Text('Hủy đơn hàng'),
                            ),
                          ),
                        if (effectiveStatus == 'Đã giao')
                          CheckboxListTile(
                            value: order.isReceivedConfirmed,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: order.isReceivedConfirmed
                                ? null
                                : (_) {
                                    context.read<OrderProvider>().confirmReceived(
                                          order.id,
                                        );
                                  },
                            title: Text(
                              order.isReceivedConfirmed
                                  ? 'Đã nhận được hàng (đã xác nhận)'
                                  : 'Tôi đã nhận được hàng',
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
