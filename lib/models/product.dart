class Product {
  const Product({
    required this.id,
    required this.title,
    this.description = '',
    this.price = 0,
    this.imageUrl = '',
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
}
