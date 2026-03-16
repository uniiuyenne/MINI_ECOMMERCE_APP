import 'package:flutter/material.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryTap,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final visible = ['Tất cả', ...categories.take(30)];

    return SizedBox(
      height: 126,
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: visible.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.25,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemBuilder: (_, index) {
          final category = visible[index];
          final isSelected = selectedCategory == category;

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onCategoryTap(category),
            child: Container(
              width: 86,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.grey.shade100,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    _iconForCategory(category),
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    category,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10.5, height: 1.05),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _iconForCategory(String category) {
    final text = category.toLowerCase();
    final normalized = text.replaceAll('-', ' ').replaceAll('_', ' ');

    if (text == 'tất cả' || normalized == 'all') {
      return Icons.grid_view;
    }

    if (normalized.contains('thời trang nam') || normalized.contains("men's clothing") || normalized.contains('mens shirts') || normalized.contains('tops')) {
      return Icons.checkroom;
    }
    if (normalized.contains('thời trang nữ') || normalized.contains("women's clothing") || normalized.contains('womens dresses')) {
      return Icons.dry_cleaning;
    }
    if (normalized.contains('điện tử') || normalized.contains('electronics')) {
      return Icons.memory;
    }
    if (normalized.contains('trang sức') || normalized.contains('jewelery') || normalized.contains('jewellery') || normalized.contains('womens jewellery')) {
      return Icons.diamond;
    }
    if (normalized.contains('điện thoại') || normalized.contains('smartphones')) {
      return Icons.phone_android;
    }
    if (normalized.contains('mỹ phẩm') || normalized.contains('beauty') || normalized.contains('skin care') || normalized.contains('chăm sóc cá nhân') || normalized.contains('cham soc ca nhan')) {
      return Icons.face_retouching_natural;
    }
    if (normalized.contains('đồ gia dụng') || normalized.contains('thiết bị nhà bếp') || normalized.contains('kitchen accessories') || normalized.contains('home decoration')) {
      return Icons.kitchen;
    }
    if (normalized.contains('mẹ và bé') || normalized.contains('me va be')) {
      return Icons.child_care;
    }
    if (normalized.contains('sách') || normalized.contains('books')) {
      return Icons.menu_book;
    }
    if (normalized.contains('thể thao') || normalized.contains('sports accessories')) {
      return Icons.sports_soccer;
    }
    if (normalized.contains('giày dép') || normalized.contains('mens shoes') || normalized.contains('womens shoes')) {
      return Icons.hiking;
    }
    if (normalized.contains('túi ví') || normalized.contains('womens bags')) {
      return Icons.work_outline;
    }
    if (normalized.contains('đồng hồ') || normalized.contains('mens watches') || normalized.contains('womens watches')) {
      return Icons.watch;
    }
    if (normalized.contains('laptop') || normalized.contains('laptops')) {
      return Icons.laptop_mac;
    }
    if (normalized.contains('máy tính bảng') || normalized.contains('may tinh bang') || normalized.contains('tablets')) {
      return Icons.tablet_mac;
    }
    if (normalized.contains('phụ kiện') || normalized.contains('mobile accessories') || normalized.contains('sunglasses')) {
      return Icons.headphones;
    }
    if (normalized.contains('thực phẩm') || normalized.contains('groceries')) {
      return Icons.fastfood;
    }
    if (normalized.contains('đồ uống')) {
      return Icons.local_cafe;
    }
    if (normalized.contains('văn phòng phẩm') || normalized.contains('van phong pham')) {
      return Icons.edit_note;
    }
    if (normalized.contains('đồ chơi')) {
      return Icons.toys;
    }
    if (normalized.contains('nội thất') || normalized.contains('furniture')) {
      return Icons.weekend;
    }
    if (normalized.contains('thú cưng') || normalized.contains('thu cung')) {
      return Icons.pets;
    }
    if (normalized.contains('thiết bị mạng') || normalized.contains('thiet bi mang')) {
      return Icons.router;
    }
    if (normalized.contains('âm thanh') || normalized.contains('am thanh')) {
      return Icons.speaker_group;
    }
    if (normalized.contains('đồ cắm trại') || normalized.contains('do cam trai')) {
      return Icons.forest;
    }
    if (normalized.contains('xe máy') || normalized.contains('motorcycle')) {
      return Icons.two_wheeler;
    }
    if (normalized.contains('ô tô') || normalized.contains('vehicle')) {
      return Icons.directions_car;
    }
    if (normalized.contains('sức khỏe') || normalized.contains('health')) {
      return Icons.health_and_safety;
    }
    if (normalized.contains('đồ du lịch')) {
      return Icons.luggage;
    }
    if (normalized.contains('quà tặng')) {
      return Icons.card_giftcard;
    }
    if (normalized.contains('khuyến mãi')) {
      return Icons.local_offer;
    }

    return Icons.category;
  }
}
