import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/account_profile_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_smart_image.dart';
import '../home/home_screen.dart';
import '../orders/orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String _paymentMethod = 'COD';
  bool _didPrefillProfile = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _prefillCheckoutInfo(AccountProfileProvider accountProfileProvider) {
    final profile = accountProfileProvider.profile;
    if (profile == null || _didPrefillProfile) {
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      _addressController.text = profile.shippingAddress;
    }
    if (_phoneController.text.trim().isEmpty) {
      _phoneController.text = profile.phoneNumber;
    }
    _didPrefillProfile = true;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _placeOrder() async {
    if (_isSubmitting) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final orderProvider = context.read<OrderProvider>();

    if (!authProvider.isLoggedIn) {
      _showMessage('Vui lòng đăng nhập để lưu đơn hàng vào lịch sử mua hàng.');
      return;
    }

    final address = _addressController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    if (address.isEmpty) {
      _showMessage('Vui lòng nhập địa chỉ nhận hàng');
      return;
    }

    if (phoneNumber.isEmpty) {
      _showMessage('Vui lòng nhập số điện thoại nhận hàng');
      return;
    }

    final selected = cart.selectedItems;
    if (selected.isEmpty) {
      _showMessage('Bạn chưa chọn sản phẩm nào để đặt hàng.');
      return;
    }

    setState(() => _isSubmitting = true);
    _showMessage('Đang xử lý đơn hàng...');

    bool success = false;
    bool isTimeout = false;
    try {
      success = await orderProvider
          .placeOrder(
            items: selected,
            total: cart.selectedTotal,
            address: address,
            phoneNumber: phoneNumber,
            paymentMethod: _paymentMethod,
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      success = false;
      isTimeout = true;
      if (mounted) {
        _showMessage(
          'Đặt hàng đang mất quá lâu. Hãy kiểm tra kết nối Firebase/Internet rồi thử lại.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }

    if (!success) {
      if (!mounted) {
        return;
      }
      if (isTimeout) {
        return;
      }
      _showMessage(
        orderProvider.error ?? 'Không thể lưu đơn hàng. Vui lòng thử lại.',
      );
      return;
    }

    if (mounted && orderProvider.placeOrderNotice != null) {
      _showMessage(orderProvider.placeOrderNotice!);
    }

    await cart.removeSelected();

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đặt hàng thành công'),
        content: const Text('Đơn hàng của bạn đã được ghi nhận.'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final accountProfileProvider = context.watch<AccountProfileProvider>();
    _prefillCheckoutInfo(accountProfileProvider);
    final selected = cart.selectedItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              );
            },
            icon: const Icon(Icons.receipt_long_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Sản phẩm đã chọn',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...selected.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: AppSmartImage(
                imageUrl: item.product.image,
                category: item.product.displayCategory,
                label: item.product.displayTitle,
                width: 44,
                height: 44,
                borderRadius: 8,
                iconSize: 18,
                fontSize: 9,
              ),
              title: Text(
                item.product.displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('${item.size}/${item.color} x${item.quantity}'),
              trailing: Text(
                Formatters.currency(item.subtotal * 25000),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const Divider(height: 24),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Địa chỉ nhận hàng',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Số điện thoại nhận hàng',
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Phương thức thanh toán',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _paymentMethod,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'COD', child: Text('COD')),
              DropdownMenuItem(value: 'Momo', child: Text('Momo')),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _paymentMethod = value);
            },
          ),
          const SizedBox(height: 14),
          Text(
            'Tổng thanh toán: ${Formatters.currency(cart.selectedTotal * 25000)}',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: selected.isEmpty || _isSubmitting ? null : _placeOrder,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Đặt hàng'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              );
            },
            child: const Text('Xem đơn mua'),
          ),
        ],
      ),
    );
  }
}
