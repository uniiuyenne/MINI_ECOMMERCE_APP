import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int value;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _button(icon: Icons.remove, onPressed: onDecrease),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        _button(icon: Icons.add, onPressed: onIncrease),
      ],
    );
  }

  Widget _button({required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: 28,
      height: 28,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(color: Colors.grey.shade400),
        ),
        onPressed: onPressed,
        child: Icon(icon, size: 14),
      ),
    );
  }
}
