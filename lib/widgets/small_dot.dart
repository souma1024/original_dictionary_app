import 'package:flutter/material.dart';

/// 左側の小さい丸
class SmallDot extends StatelessWidget {
  final Color color;
  const SmallDot({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  static Color colorFromName(String name) {
    final hash = name.runes.fold<int>(0, (p, c) => 0x1fffffff & (p * 31 + c));
    final hue = (hash % 360).toDouble();
    final hsl = HSLColor.fromAHSL(1, hue, 0.45, 0.55);
    return hsl.toColor();
  }
}

