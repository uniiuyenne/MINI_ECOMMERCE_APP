import 'package:flutter/material.dart';

import '../../widgets/banner_slider.dart';
import '../../widgets/category_grid.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MINI E-COMMERCE APP Skeleton')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          BannerSlider(),
          SizedBox(height: 16),
          CategoryGrid(),
          SizedBox(height: 16),
          ProductCard(title: 'Placeholder product card'),
        ],
      ),
    );
  }
}
