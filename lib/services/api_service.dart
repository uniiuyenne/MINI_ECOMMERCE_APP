import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ApiService {
  static const _baseUrl = 'https://dummyjson.com';
  static const _pageSize = 100;

  Future<List<Product>> fetchProducts() async {
    try {
      final products = <Product>[];
      var skip = 0;
      var total = 0;

      do {
        final response = await http.get(
          Uri.parse('$_baseUrl/products?limit=$_pageSize&skip=$skip'),
        );
        if (response.statusCode != 200) {
          throw Exception('Failed to load products: ${response.statusCode}');
        }

        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Invalid product payload');
        }

        final rawProducts = decoded['products'];
        if (rawProducts is! List<dynamic>) {
          throw const FormatException('Invalid products list');
        }

        total = (decoded['total'] as num?)?.toInt() ?? 0;

        final mappedPage = rawProducts
            .whereType<Map<String, dynamic>>()
            .map(_mapDummyJsonProduct)
            .toList();
        products.addAll(mappedPage);

        skip += rawProducts.length;
      } while (skip < total);

      if (products.isEmpty) {
        throw const FormatException('Empty product payload');
      }

      return products;
    } catch (error) {
      throw Exception('Khong the tai danh sach san pham tu DummyJSON API: $error');
    }
  }

  Product _mapDummyJsonProduct(Map<String, dynamic> json) {
    final images = (json['images'] as List<dynamic>?)
            ?.whereType<String>()
            .toList() ??
        const <String>[];

    final thumbnail = json['thumbnail'] as String? ?? '';
    final image = thumbnail.isNotEmpty
        ? thumbnail
        : (images.isNotEmpty ? images.first : '');

    final rating = (json['rating'] as num?)?.toDouble() ?? 0;
    final reviewCount = (json['reviews'] as List<dynamic>?)?.length;
    final stock = (json['stock'] as num?)?.toInt();

    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      image: image,
      rating: rating,
      ratingCount: reviewCount ?? stock ?? 0,
    );
  }
}
