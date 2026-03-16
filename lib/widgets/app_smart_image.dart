import 'package:flutter/material.dart';

class AppSmartImage extends StatelessWidget {
  const AppSmartImage({
    super.key,
    required this.imageUrl,
    required this.category,
    required this.label,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 12,
    this.iconSize = 28,
    this.fontSize = 11,
  });

  final String imageUrl;
  final String category;
  final String label;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final placeholder = _PlaceholderCard(
      category: category,
      label: label,
      iconSize: iconSize,
      fontSize: fontSize,
    );
    final fallbackImageUrl = _realFallbackImageUrl(label, category);

    // Decide which network URL to try first: prefer provided imageUrl when non-empty.
    // Skip known-broken / deprecated image hosts so the fallback is used immediately.
    final raw = imageUrl.trim();
    final isBrokenSource = raw.isEmpty ||
      raw.contains('placehold.co') ||
      raw.contains('dummyimage.com') ||
      raw.contains('source.unsplash.com');
    final primaryImageUrl = isBrokenSource ? fallbackImageUrl : raw;

    if (raw.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              placeholder,
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              primaryImageUrl,
              fit: fit,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) {
                  return child;
                }
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 250),
                  child: child,
                );
              },
              loadingBuilder: (context, child, progress) {
                if (progress == null) {
                  return child;
                }
                return placeholder;
              },
              errorBuilder: (context, error, stackTrace) =>
                  // If primary failed and it's not the same as fallback, try fallback once
                  (primaryImageUrl != fallbackImageUrl)
                      ? Image.network(
                          fallbackImageUrl,
                          fit: fit,
                          errorBuilder: (context, error, stackTrace) => placeholder,
                        )
                      : placeholder,
            ),
            // Overlay product name on top of the image
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _realFallbackImageUrl(String label, String category) {
    // Use loremflickr.com — CORS-enabled, deterministic via lock param.
    final keyword = _categoryKeyword(category);
    final lock = ('$label$category').hashCode.abs() % 9999 + 1;
    return 'https://loremflickr.com/400/400/$keyword?lock=$lock';
  }

  static String _categoryKeyword(String category) {
    const map = <String, String>{
      'Giày dép':       'shoes',
      'Máy tính':       'laptop',
      'Mỹ phẩm':        'cosmetics',
      'Phụ kiện':       'headphones',
      'Sách':           'book',
      'Thiết bị':       'electronic',
      'Thể thao':       'sports',
      'Văn phòng':      'stationery',
      'Ô tô':           'automobile',
      'Điện tử':        'electronics',
      'Đồ du lịch':     'luggage',
      'Đồ uống':        'beverage',
      'Nội thất':       'furniture',
      'Quà tặng':       'gift',
      'Sức khỏe':       'healthcare',
      'Thực phẩm':      'food',
      'Túi ví':         'handbag',
      'Xe máy':         'motorcycle',
      'Điện thoại':     'smartphone',
      'Đồ chơi':        'toy',
      'Đồ gia dụng':    'appliance',
      'Đồng hồ':        'wristwatch',
      'Trang sức':      'jewelry',
      'Thời trang nam': 'fashion',
      'Thời trang nữ':  'fashion',
      'electronics':    'electronics',
      'jewelery':       'jewelry',
      "men's clothing": 'fashion',
      "women's clothing": 'fashion',
    };
    return map[category] ?? 'product';
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({
    required this.category,
    required this.label,
    required this.iconSize,
    required this.fontSize,
  });

  final String category;
  final String label;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForProduct(label, category);
    final emoji = _emojiForProduct(label, category);
    final icon = _iconForProduct(label, category);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      emoji,
                      style: TextStyle(fontSize: iconSize + 8),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      icon,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _shortLabel(label),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _shortLabel(String label) {
    final parts = label.split(' ');
    if (parts.length <= 3) {
      return label;
    }
    return parts.take(3).join(' ');
  }

  static IconData _iconForProduct(String label, String category) {
    final text = label.toLowerCase();
    if (text.contains('sneaker') || text.contains('chạy bộ')) return Icons.hiking;
    if (text.contains('giày tây')) return Icons.business_center;
    if (text.contains('sandal')) return Icons.woman;
    if (text.contains('pc') || text.contains('máy tính')) return Icons.computer;
    if (text.contains('serum') || text.contains('kem chống nắng') || text.contains('sữa rửa mặt')) {
      return Icons.spa;
    }
    if (text.contains('tai nghe')) return Icons.headphones;
    if (text.contains('sạc') || text.contains('cáp')) return Icons.cable;
    if (text.contains('sách') || text.contains('tư duy') || text.contains('tài chính')) {
      return Icons.menu_book;
    }
    if (text.contains('máy in')) return Icons.print;
    if (text.contains('camera')) return Icons.videocam;
    if (text.contains('wi-fi') || text.contains('mesh')) return Icons.router;
    if (text.contains('thảm yoga')) return Icons.self_improvement;
    if (text.contains('bình nước')) return Icons.sports_gymnastics;
    if (text.contains('bút')) return Icons.edit;
    if (text.contains('sổ tay')) return Icons.sticky_note_2;
    if (text.contains('casio')) return Icons.calculate;
    if (text.contains('hút bụi')) return Icons.cleaning_services;
    if (text.contains('ô tô') || text.contains('điện thoại gắn xe')) return Icons.directions_car;
    if (text.contains('smart tv')) return Icons.tv;
    if (text.contains('loa')) return Icons.speaker;
    if (text.contains('vali')) return Icons.luggage;
    if (text.contains('ba lô')) return Icons.backpack;
    if (text.contains('túi đựng đồ')) return Icons.inventory_2;
    if (text.contains('nước cam') || text.contains('trà') || text.contains('cà phê')) {
      return Icons.local_drink;
    }
    if (text.contains('bàn làm việc')) return Icons.table_restaurant;
    if (text.contains('ghế')) return Icons.chair_alt;
    if (text.contains('kệ sách')) return Icons.shelves;
    if (text.contains('hộp quà')) return Icons.card_giftcard;
    if (text.contains('gấu bông')) return Icons.toys;
    if (text.contains('nến')) return Icons.mode_night;
    if (text.contains('huyết áp') || text.contains('nhiệt kế') || text.contains('vitamin')) {
      return Icons.health_and_safety;
    }
    if (text.contains('gạo') || text.contains('yến mạch') || text.contains('gia vị')) {
      return Icons.restaurant;
    }
    if (text.contains('túi') || text.contains('ví')) return Icons.shopping_bag;
    if (text.contains('mũ bảo hiểm')) return Icons.safety_check;
    if (text.contains('găng tay')) return Icons.back_hand;
    if (text.contains('giá đỡ')) return Icons.phone_android;
    if (text.contains('iphone') || text.contains('galaxy') || text.contains('redmi')) {
      return Icons.phone_iphone;
    }
    if (text.contains('robot')) return Icons.smart_toy;
    if (text.contains('nhà bếp mini')) return Icons.soup_kitchen;
    if (text.contains('xe điều khiển')) return Icons.toys;
    if (text.contains('nồi chiên') || text.contains('bình đun')) return Icons.kitchen;
    if (text.contains('máy lọc không khí')) return Icons.air;
    if (text.contains('đồng hồ') || text.contains('smartwatch')) return Icons.watch;

    return _iconForCategory(category);
  }

  static String _emojiForProduct(String label, String category) {
    final text = label.toLowerCase();
    if (text.contains('sneaker') || text.contains('chạy bộ')) return '👟';
    if (text.contains('giày tây')) return '👞';
    if (text.contains('sandal')) return '👡';
    if (text.contains('pc') || text.contains('máy tính')) return '🖥️';
    if (text.contains('serum')) return '🧴';
    if (text.contains('kem chống nắng')) return '☀️';
    if (text.contains('sữa rửa mặt')) return '🫧';
    if (text.contains('tai nghe')) return '🎧';
    if (text.contains('sạc') || text.contains('cáp')) return '🔌';
    if (text.contains('sách') || text.contains('tư duy') || text.contains('tài chính')) return '📘';
    if (text.contains('máy in')) return '🖨️';
    if (text.contains('camera')) return '📷';
    if (text.contains('wi-fi') || text.contains('mesh')) return '📶';
    if (text.contains('thảm yoga')) return '🧘';
    if (text.contains('bình nước')) return '💧';
    if (text.contains('bút')) return '✏️';
    if (text.contains('sổ tay')) return '📓';
    if (text.contains('casio')) return '🧮';
    if (text.contains('hút bụi')) return '🚗';
    if (text.contains('ô tô')) return '🚘';
    if (text.contains('smart tv')) return '📺';
    if (text.contains('loa')) return '🔊';
    if (text.contains('vali')) return '🧳';
    if (text.contains('ba lô')) return '🎒';
    if (text.contains('túi đựng đồ')) return '🧺';
    if (text.contains('nước cam')) return '🧃';
    if (text.contains('cà phê')) return '☕';
    if (text.contains('trà')) return '🍵';
    if (text.contains('bàn làm việc')) return '🪵';
    if (text.contains('ghế')) return '🪑';
    if (text.contains('kệ sách')) return '🗄️';
    if (text.contains('hộp quà')) return '🎁';
    if (text.contains('gấu bông')) return '🧸';
    if (text.contains('nến')) return '🕯️';
    if (text.contains('huyết áp')) return '🩺';
    if (text.contains('nhiệt kế')) return '🌡️';
    if (text.contains('vitamin')) return '💊';
    if (text.contains('gạo')) return '🍚';
    if (text.contains('yến mạch')) return '🌾';
    if (text.contains('gia vị')) return '🧂';
    if (text.contains('túi') || text.contains('ví')) return '👜';
    if (text.contains('mũ bảo hiểm')) return '🪖';
    if (text.contains('găng tay')) return '🧤';
    if (text.contains('giá đỡ')) return '📱';
    if (text.contains('iphone') || text.contains('galaxy') || text.contains('redmi')) return '📱';
    if (text.contains('robot')) return '🤖';
    if (text.contains('nhà bếp mini')) return '🍳';
    if (text.contains('xe điều khiển')) return '🚗';
    if (text.contains('nồi chiên')) return '🍟';
    if (text.contains('máy lọc không khí')) return '💨';
    if (text.contains('bình đun')) return '🫖';
    if (text.contains('đồng hồ') || text.contains('smartwatch')) return '⌚';

    return _emojiForCategory(category);
  }

  static IconData _iconForCategory(String category) {
    final text = category.toLowerCase();
    if (text.contains('thời trang nam')) return Icons.checkroom;
    if (text.contains('thời trang nữ')) return Icons.dry_cleaning;
    if (text.contains('giày')) return Icons.hiking;
    if (text.contains('máy tính')) return Icons.computer;
    if (text.contains('điện thoại')) return Icons.phone_android;
    if (text.contains('mỹ phẩm')) return Icons.face_retouching_natural;
    if (text.contains('phụ kiện')) return Icons.headphones;
    if (text.contains('sách')) return Icons.menu_book;
    if (text.contains('thiết bị')) return Icons.memory;
    if (text.contains('thể thao')) return Icons.sports_soccer;
    if (text.contains('văn phòng')) return Icons.edit_note;
    if (text.contains('ô tô')) return Icons.directions_car;
    if (text.contains('điện tử')) return Icons.devices;
    if (text.contains('du lịch')) return Icons.luggage;
    if (text.contains('đồ uống')) return Icons.local_cafe;
    if (text.contains('nội thất')) return Icons.weekend;
    if (text.contains('quà tặng')) return Icons.card_giftcard;
    if (text.contains('sức khỏe')) return Icons.health_and_safety;
    if (text.contains('thực phẩm')) return Icons.fastfood;
    if (text.contains('túi ví')) return Icons.work_outline;
    if (text.contains('xe máy')) return Icons.two_wheeler;
    if (text.contains('đồ chơi')) return Icons.toys;
    if (text.contains('gia dụng')) return Icons.kitchen;
    if (text.contains('đồng hồ')) return Icons.watch;
    if (text.contains('trang sức')) return Icons.diamond;
    return Icons.inventory_2;
  }

  static String _emojiForCategory(String category) {
    final text = category.toLowerCase();
    if (text.contains('giày')) return '👟';
    if (text.contains('máy tính')) return '🖥️';
    if (text.contains('điện thoại')) return '📱';
    if (text.contains('mỹ phẩm')) return '🧴';
    if (text.contains('sách')) return '📘';
    if (text.contains('văn phòng')) return '✏️';
    if (text.contains('ô tô')) return '🚗';
    if (text.contains('điện tử')) return '📺';
    if (text.contains('du lịch')) return '🧳';
    if (text.contains('đồ uống')) return '☕';
    if (text.contains('nội thất')) return '🪑';
    if (text.contains('quà tặng')) return '🎁';
    if (text.contains('sức khỏe')) return '💊';
    if (text.contains('thực phẩm')) return '🍚';
    if (text.contains('túi ví')) return '👜';
    if (text.contains('xe máy')) return '🪖';
    if (text.contains('đồ chơi')) return '🧸';
    if (text.contains('gia dụng')) return '🍳';
    if (text.contains('đồng hồ')) return '⌚';
    return '📦';
  }

  static List<Color> _colorsForProduct(String label, String category) {
    final text = label.toLowerCase();
    if (text.contains('iphone') || text.contains('galaxy') || text.contains('redmi')) {
      return const [Color(0xFF0D47A1), Color(0xFF64B5F6)];
    }
    if (text.contains('sneaker') || text.contains('giày') || text.contains('sandal')) {
      return const [Color(0xFF6A1B9A), Color(0xFFCE93D8)];
    }
    if (text.contains('serum') || text.contains('kem chống nắng') || text.contains('sữa rửa mặt')) {
      return const [Color(0xFFAD1457), Color(0xFFF48FB1)];
    }
    if (text.contains('cà phê') || text.contains('trà') || text.contains('nước cam')) {
      return const [Color(0xFFEF6C00), Color(0xFFFFCC80)];
    }
    if (text.contains('bàn') || text.contains('ghế') || text.contains('kệ')) {
      return const [Color(0xFF5D4037), Color(0xFFBCAAA4)];
    }
    if (text.contains('huyết áp') || text.contains('nhiệt kế') || text.contains('vitamin')) {
      return const [Color(0xFF2E7D32), Color(0xFFA5D6A7)];
    }
    return _colorsForCategory(category);
  }

  static List<Color> _colorsForCategory(String category) {
    final text = category.toLowerCase();
    if (text.contains('điện thoại') || text.contains('máy tính') || text.contains('điện tử')) {
      return const [Color(0xFF1565C0), Color(0xFF42A5F5)];
    }
    if (text.contains('thời trang') || text.contains('túi ví') || text.contains('giày')) {
      return const [Color(0xFF8E24AA), Color(0xFFCE93D8)];
    }
    if (text.contains('mỹ phẩm') || text.contains('quà tặng')) {
      return const [Color(0xFFD81B60), Color(0xFFF48FB1)];
    }
    if (text.contains('sức khỏe') || text.contains('thực phẩm') || text.contains('đồ uống')) {
      return const [Color(0xFF2E7D32), Color(0xFF81C784)];
    }
    if (text.contains('ô tô') || text.contains('xe máy') || text.contains('thiết bị')) {
      return const [Color(0xFF455A64), Color(0xFF90A4AE)];
    }
    return const [Color(0xFFFF7043), Color(0xFFFFAB91)];
  }
}
