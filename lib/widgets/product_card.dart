import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/formatters.dart';
import 'app_smart_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  static const _tags = ['Mall', 'Yêu thích', 'Giảm 50%'];

  @override
  Widget build(BuildContext context) {
    final tag = _tags[product.id % _tags.length];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Hero(
                  tag: 'product_${product.id}',
                  child: AppSmartImage(
                    imageUrl: product.image,
                    category: product.displayCategory,
                    label: product.displayTitle,
                    borderRadius: 10,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.displayTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                Formatters.currency(product.price * 25000),
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                Formatters.soldCount(product.ratingCount * 20),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
