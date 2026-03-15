class CartItem {
  const CartItem({
    required this.id,
    required this.productId,
    required this.title,
    this.quantity = 1,
    this.unitPrice = 0,
    this.isSelected = true,
  });

  final String id;
  final String productId;
  final String title;
  final int quantity;
  final double unitPrice;
  final bool isSelected;
}
