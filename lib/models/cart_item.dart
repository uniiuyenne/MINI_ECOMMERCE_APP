import 'product.dart';

class CartItem {
  final Product product;
  final String size;
  final String color;
  final int quantity;
  final bool isSelected;

  const CartItem({
    required this.product,
    required this.size,
    required this.color,
    required this.quantity,
    this.isSelected = true,
  });

  String get key => '${product.id}_${size}_$color';

  double get subtotal => product.price * quantity;

  CartItem copyWith({
    Product? product,
    String? size,
    String? color,
    int? quantity,
    bool? isSelected,
  }) {
    return CartItem(
      product: product ?? this.product,
      size: size ?? this.size,
      color: color ?? this.color,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'size': size,
      'color': color,
      'quantity': quantity,
      'isSelected': isSelected,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      size: json['size'] as String? ?? 'M',
      color: json['color'] as String? ?? 'Đỏ',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      isSelected: json['isSelected'] as bool? ?? true,
    );
  }
}
