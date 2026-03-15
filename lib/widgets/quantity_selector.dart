import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.value,
    this.onDecrease,
    this.onIncrease,
  });

  final int value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: onDecrease, icon: const Icon(Icons.remove)),
        Text('$value'),
        IconButton(onPressed: onIncrease, icon: const Icon(Icons.add)),
      ],
    );
  }
}
