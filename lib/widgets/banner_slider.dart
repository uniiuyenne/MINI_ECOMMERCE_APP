import 'dart:async';

import 'package:flutter/material.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _controller = PageController();
  int _current = 0;
  Timer? _timer;

  static const _banners = [
    (
      'https://picsum.photos/seed/freeship-sale/1200/500',
      'Freeship toàn quốc',
      'Đơn từ 99.000đ nhận voucher vận chuyển',
    ),
    (
      'https://picsum.photos/seed/fashion-deal/1200/500',
      'Thời trang giảm sâu',
      'Nhiều mẫu mới cho nam và nữ giá tốt hôm nay',
    ),
    (
      'https://picsum.photos/seed/tech-week/1200/500',
      'Công nghệ nổi bật',
      'Laptop, điện thoại và phụ kiện đang được quan tâm',
    ),
    (
      'https://picsum.photos/seed/home-living/1200/500',
      'Gia dụng & nội thất',
      'Chọn nhanh đồ dùng tiện ích cho gia đình',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) {
        return;
      }
      _current = (_current + 1) % _banners.length;
      _controller.animateToPage(
        _current,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            onPageChanged: (index) => setState(() => _current = index),
            itemBuilder: (_, index) {
              final banner = _banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        banner.$1,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) {
                            return child;
                          }
                          return _buildFallbackBanner(banner.$2, banner.$3);
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFallbackBanner(banner.$2, banner.$3);
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.18),
                              Colors.black.withValues(alpha: 0.52),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              banner.$2,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              banner.$3,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _current == index ? 18 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: _current == index
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackBanner(String title, String subtitle) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF90CAF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
