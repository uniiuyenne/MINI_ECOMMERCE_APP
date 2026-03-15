import 'package:flutter/material.dart';

class AppSmartImage extends StatelessWidget {
  const AppSmartImage({
    super.key,
    this.imageUrl,
    this.height = 120,
    this.width,
  });

  final String? imageUrl;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.startsWith('http')) {
      return Image.network(
        imageUrl!,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _PlaceholderCard(height: height, width: width),
      );
    }

    return _PlaceholderCard(height: height, width: width);
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({required this.height, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image_outlined),
    );
  }
}
