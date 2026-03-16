import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/banner_slider.dart';
import '../../widgets/cart_badge_icon.dart';
import '../../widgets/category_grid.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isScrolled = false;
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().initialLoad();
    });

    _scrollController.addListener(() {
      final provider = context.read<ProductProvider>();
      if (_scrollController.position.pixels > 30 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.position.pixels <= 30 && _isScrolled) {
        setState(() => _isScrolled = false);
      }

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 250) {
        provider.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSelectedCategory(String category, String title, String description) {
    final selected = _selectedCategory.toLowerCase();
    if (selected == 'tất cả') {
      return true;
    }

    final normalizedCategory = category.toLowerCase();
    return normalizedCategory == selected;
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    if (_selectedCategory != 'Tất cả' &&
        !productProvider.categories.contains(_selectedCategory)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() => _selectedCategory = 'Tất cả');
      });
    }

    final visibleProducts = productProvider.products.where((product) {
      if (!_matchesSelectedCategory(
        product.displayCategory,
        product.displayTitle,
        product.displayDescription,
      )) {
        return false;
      }

      final query = _searchQuery.trim().toLowerCase();
      if (query.isEmpty) {
        return true;
      }

      return product.displayTitle.toLowerCase().contains(query) ||
          product.displayCategory.toLowerCase().contains(query) ||
          product.displayDescription.toLowerCase().contains(query) ||
          product.title.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: productProvider.refresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              expandedHeight: 90,
              title: const Text('TH4 - Nhóm 08'),
              foregroundColor: _isScrolled ? Colors.white : Colors.black87,
              elevation: 0,
              backgroundColor: _isScrolled
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              flexibleSpace: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                color: _isScrolled
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              actions: [
                CartBadgeIcon(
                  onTap: () {},
                  iconColor: _isScrolled ? Colors.white : Colors.black,
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm sản phẩm...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.trim().isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                                icon: const Icon(Icons.clear),
                              ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(top: 10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BannerSlider(),
                    if (productProvider.categories.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(12, 10, 12, 8),
                        child: Text(
                          'Danh mục',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    if (productProvider.categories.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: CategoryGrid(
                          categories: productProvider.categories,
                          selectedCategory: _selectedCategory,
                          onCategoryTap: (value) {
                            setState(() => _selectedCategory = value);
                          },
                        ),
                      ),
                    if (_selectedCategory != 'Tất cả')
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Đang lọc: $_selectedCategory',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(() => _selectedCategory = 'Tất cả'),
                              child: const Text('Bỏ lọc'),
                            ),
                          ],
                        ),
                      ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12, 10, 12, 8),
                      child: Text(
                        'Gợi ý hôm nay',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (productProvider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (productProvider.error != null)
              SliverFillRemaining(
                child: Center(child: Text(productProvider.error!)),
              )
            else if (visibleProducts.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    _searchQuery.trim().isEmpty
                        ? 'Chưa có sản phẩm hiển thị'
                        : 'Không tìm thấy sản phẩm phù hợp',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) {
                      final product = visibleProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          context.read<CartProvider>().addToCart(
                                product: product,
                                size: 'M',
                                color: 'Đỏ',
                                quantity: 1,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã thêm vào giỏ hàng')),
                          );
                        },
                      );
                    },
                    childCount: visibleProducts.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.62,
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: productProvider.isLoadMore
                      ? const CircularProgressIndicator()
                      : productProvider.hasMore
                          ? const SizedBox.shrink()
                          : const Text('Đã hiển thị hết sản phẩm'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
