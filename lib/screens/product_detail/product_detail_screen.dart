import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/app_smart_image.dart';
import '../../widgets/cart_badge_icon.dart';
import '../../widgets/quantity_selector.dart';
import '../cart/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _expanded = false;

  Future<void> _openVariationSheet({bool buyNow = false}) async {
    final variationOptions = _VariationOptions.fromProduct(widget.product);
    final result = await showModalBottomSheet<_VariationData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => _VariationSheet(options: variationOptions),
    );

    if (!mounted || result == null) {
      return;
    }

    await context.read<CartProvider>().addToCart(
          product: widget.product,
          size: result.size,
          color: result.color,
          quantity: result.quantity,
        );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(buyNow ? 'Đã thêm và chuyển sang giỏ hàng' : 'Thêm thành công'),
      ),
    );

    if (buyNow) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CartScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final fakeGallery = [product.image, product.image, product.image];
    final oldPrice = product.price * 1.25 * 25000;
    final newPrice = product.price * 25000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        actions: [
          CartBadgeIcon(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 320,
            child: PageView.builder(
              itemCount: fakeGallery.length,
              itemBuilder: (_, index) {
                return Hero(
                  tag: 'product_${product.id}',
                  child: AppSmartImage(
                    imageUrl: fakeGallery[index],
                    category: product.displayCategory,
                    label: product.displayTitle,
                    fit: BoxFit.contain,
                    borderRadius: 0,
                    iconSize: 48,
                    fontSize: 14,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Formatters.currency(newPrice),
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.currency(oldPrice),
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  product.displayTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _openVariationSheet,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Phân loại: Chọn Kích cỡ, Màu sắc',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mô tả chi tiết',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  product.displayDescription,
                  maxLines: _expanded ? null : 5,
                  overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: const TextStyle(height: 1.4),
                ),
                TextButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  child: Text(_expanded ? 'Thu gọn' : 'Xem thêm'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
        ),
        child: Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.chat_outlined)),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
            Expanded(
              child: OutlinedButton(
                onPressed: _openVariationSheet,
                child: const Text('Thêm vào giỏ'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _openVariationSheet(buyNow: true),
                child: const Text('Mua ngay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VariationData {
  const _VariationData({
    required this.size,
    required this.color,
    required this.quantity,
  });

  final String size;
  final String color;
  final int quantity;
}

class _VariationSheet extends StatefulWidget {
  const _VariationSheet({required this.options});

  final _VariationOptions options;

  @override
  State<_VariationSheet> createState() => _VariationSheetState();
}

class _VariationSheetState extends State<_VariationSheet> {
  late String _size;
  late String _color;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _size = widget.options.sizes.first;
    _color = widget.options.colors.first;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: SizedBox(
              width: 40,
              child: Divider(thickness: 4),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Chọn kích cỡ', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: widget.options.sizes
                .map(
                  (size) => ChoiceChip(
                    label: Text(size),
                    selected: _size == size,
                    onSelected: (_) => setState(() => _size = size),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          const Text('Chọn màu sắc', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: widget.options.colors
                .map(
                  (color) => ChoiceChip(
                    label: Text(color),
                    selected: _color == color,
                    onSelected: (_) => setState(() => _color = color),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text('Số lượng', style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              QuantitySelector(
                value: _quantity,
                onDecrease: () {
                  if (_quantity == 1) {
                    return;
                  }
                  setState(() => _quantity--);
                },
                onIncrease: () => setState(() => _quantity++),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  _VariationData(size: _size, color: _color, quantity: _quantity),
                );
              },
              child: const Text('Xác nhận'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VariationOptions {
  const _VariationOptions({
    required this.sizes,
    required this.colors,
  });

  final List<String> sizes;
  final List<String> colors;

  factory _VariationOptions.fromProduct(Product product) {
    final category = product.category.toLowerCase();
    final title = product.title.toLowerCase();

    if (category == 'jewelery') {
      if (title.contains('ring')) {
        return const _VariationOptions(
          sizes: ['Ni 6', 'Ni 7', 'Ni 8', 'Ni 9'],
          colors: ['Vàng', 'Bạc', 'Vàng hồng'],
        );
      }
      if (title.contains('bracelet')) {
        return const _VariationOptions(
          sizes: ['16cm', '18cm', '20cm'],
          colors: ['Vàng', 'Bạc'],
        );
      }
      if (title.contains('chain')) {
        return const _VariationOptions(
          sizes: ['45cm', '50cm', '55cm'],
          colors: ['Vàng', 'Bạc', 'Vàng hồng'],
        );
      }
      return const _VariationOptions(
        sizes: ['Free size'],
        colors: ['Vàng', 'Bạc', 'Vàng hồng'],
      );
    }

    if (category == 'electronics') {
      if (title.contains('ssd')) {
        return const _VariationOptions(
          sizes: ['256GB', '512GB', '1TB'],
          colors: ['Đen', 'Bạc'],
        );
      }
      if (title.contains('monitor')) {
        return const _VariationOptions(
          sizes: ['24 inch', '27 inch', '32 inch'],
          colors: ['Đen', 'Bạc'],
        );
      }
      if (title.contains('laptop')) {
        return const _VariationOptions(
          sizes: ['8GB/256GB', '16GB/512GB'],
          colors: ['Bạc', 'Xám không gian'],
        );
      }
      return const _VariationOptions(
        sizes: ['Tiêu chuẩn'],
        colors: ['Đen', 'Trắng', 'Bạc'],
      );
    }

    if (category == "men's clothing") {
      if (title.contains('jacket')) {
        return const _VariationOptions(
          sizes: ['M', 'L', 'XL', '2XL'],
          colors: ['Đen', 'Xanh navy', 'Xám'],
        );
      }
      if (title.contains('shirt') || title.contains('t-shirt')) {
        return const _VariationOptions(
          sizes: ['S', 'M', 'L', 'XL'],
          colors: ['Trắng', 'Đen', 'Xanh navy', 'Rêu'],
        );
      }
      return const _VariationOptions(
        sizes: ['S', 'M', 'L', 'XL'],
        colors: ['Đen', 'Trắng', 'Xám', 'Xanh navy'],
      );
    }

    if (category == "women's clothing") {
      if (title.contains('jacket')) {
        return const _VariationOptions(
          sizes: ['S', 'M', 'L'],
          colors: ['Đen', 'Kem', 'Nâu'],
        );
      }
      if (title.contains('shirt')) {
        return const _VariationOptions(
          sizes: ['S', 'M', 'L'],
          colors: ['Trắng', 'Hồng pastel', 'Xanh nhạt', 'Be'],
        );
      }
      return const _VariationOptions(
        sizes: ['S', 'M', 'L'],
        colors: ['Đen', 'Trắng kem', 'Hồng pastel', 'Nâu'],
      );
    }

    return const _VariationOptions(
      sizes: ['M'],
      colors: ['Đen', 'Trắng'],
    );
  }
}
