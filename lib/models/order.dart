class Order {
  Order({
    required this.id,
    required this.itemIds,
    this.totalAmount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  final String id;
  final List<String> itemIds;
  final double totalAmount;
  final DateTime createdAt;
}
