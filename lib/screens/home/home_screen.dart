import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/account_profile_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/banner_slider.dart';
import '../../widgets/cart_badge_icon.dart';
import '../../widgets/category_grid.dart';
import '../../widgets/product_card.dart';
import '../account/account_profile_screen.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import '../orders/purchase_history_screen.dart';
import '../product_detail/product_detail_screen.dart';

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

  void _showCategorySheet(List<String> categories) {
    showGeneralDialog<void>(
      context: context,
      barrierLabel: 'Danh mục sản phẩm',
      barrierDismissible: true,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        final visibleCategories = categories.isEmpty
            ? ['Tất cả sản phẩm']
            : ['Tất cả sản phẩm', ...categories];

        return SafeArea(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: Colors.white,
              child: SizedBox(
                width: 280,
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Danh mục sản phẩm',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: visibleCategories.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: const Icon(Icons.label_outline),
                              title: Text(visibleCategories[index]),
                              onTap: () {
                                final selected = visibleCategories[index];
                                setState(() {
                                  _selectedCategory = selected == 'Tất cả sản phẩm'
                                      ? 'Tất cả'
                                      : selected;
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  bool _matchesSelectedCategory(String category, String title, String description) {
    final selected = _selectedCategory.toLowerCase();
    if (selected == 'tất cả') {
      return true;
    }

    final normalizedCategory = category.toLowerCase();
    return normalizedCategory == selected;
  }

  Future<void> _handleAccountMenuAction(
    String value,
    AuthProvider authProvider,
    AccountProfileProvider accountProfileProvider,
  ) async {
    switch (value) {
      case 'manage_account':
        if (!authProvider.isLoggedIn || accountProfileProvider.profile == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng đăng nhập để quản lý tài khoản.')),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AccountProfileScreen()),
        );
        break;
      case 'orders':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OrdersScreen()),
        );
        break;
      case 'history':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PurchaseHistoryScreen()),
        );
        break;
      case 'logout':
        if (!authProvider.isLoggedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bạn chưa đăng nhập.')),
          );
          return;
        }
        await authProvider.signOut();
        await accountProfileProvider.clearProfile();
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đăng xuất')),
        );
        break;
      case 'login':
        final success = await authProvider.signInWithGoogle();
        if (success && authProvider.user != null) {
          await accountProfileProvider.syncProfile(
            userKey: authProvider.user!.uid,
            displayName: authProvider.user!.displayName ?? '',
            email: authProvider.user!.email ?? '',
            avatarUrl: authProvider.user!.photoURL ?? '',
          );
        }
        if (!mounted) {
          return;
        }
        final message = success
            ? 'Đăng nhập Google thành công'
            : (authProvider.error ?? 'Đăng nhập thất bại');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final authProvider = context.watch<AuthProvider>();
    final accountProfileProvider = context.watch<AccountProfileProvider>();

    if (authProvider.isLoggedIn && authProvider.user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        context.read<AccountProfileProvider>().syncProfile(
              userKey: authProvider.user!.uid,
              displayName: authProvider.user!.displayName ?? '',
              email: authProvider.user!.email ?? '',
              avatarUrl: authProvider.user!.photoURL ?? '',
            );
      });
    }

    final profile = accountProfileProvider.profile;
    final userName = profile?.displayName.isNotEmpty == true
        ? profile!.displayName
        : (authProvider.user?.displayName ?? authProvider.user?.email);
    final avatarUrl = profile?.avatarUrl ?? authProvider.user?.photoURL ?? '';

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
                if (!authProvider.isLoggedIn)
                  IconButton(
                    tooltip: 'Đăng nhập Google',
                    onPressed: authProvider.isLoading
                        ? null
                        : () => _handleAccountMenuAction(
                              'login',
                              authProvider,
                              accountProfileProvider,
                            ),
                    icon: authProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.login,
                            color: _isScrolled ? Colors.white : Colors.black,
                          ),
                  )
                else
                  PopupMenuButton<String>(
                    tooltip: userName ?? 'Tài khoản',
                    onSelected: (value) =>
                        _handleAccountMenuAction(
                          value,
                          authProvider,
                          accountProfileProvider,
                        ),
                    itemBuilder: (_) => const [
                      PopupMenuItem<String>(
                        value: 'manage_account',
                        child: Text('Quản lý tài khoản cá nhân'),
                      ),
                      PopupMenuItem<String>(
                        value: 'history',
                        child: Text('Xem lịch sử mua hàng'),
                      ),
                      PopupMenuItem<String>(
                        value: 'logout',
                        child: Text('Đăng xuất'),
                      ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundImage:
                            avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl.isEmpty
                            ? Text(
                                (userName?.isNotEmpty ?? false)
                                    ? userName!.substring(0, 1).toUpperCase()
                                    : 'U',
                              )
                            : null,
                      ),
                    ),
                  ),
                CartBadgeIcon(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                  iconColor: _isScrolled ? Colors.white : Colors.black,
                ),
                IconButton(
                  tooltip: 'Trạng thái đơn hàng',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    );
                  },
                  icon: Icon(
                    Icons.receipt_long_outlined,
                    color: _isScrolled ? Colors.white : Colors.black,
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () =>
                              _showCategorySheet(productProvider.categories),
                          icon: const Icon(Icons.menu),
                          tooltip: 'Danh mục sản phẩm',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
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
                              contentPadding:
                                  const EdgeInsets.only(top: 10),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(product: product),
                            ),
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
