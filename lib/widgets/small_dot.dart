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

  /// タグ名から安定した色を作る（不透明/固定彩度・輝度）
  static Color colorFromName(String name) {
    // 名前のハッシュで 0..359 の色相を作る
    final hash = name.runes.fold<int>(0, (p, c) => 0x1fffffff & (p * 31 + c));
    final hue = (hash % 360).toDouble();
    final hsl = HSLColor.fromAHSL(1.0, hue, 0.45, 0.55); // 不透明
    return hsl.toColor();
  }

  /// Color → "0xAARRGGBB"
  static String colorToHexString(Color color) {
    final v = color.toARGB32(); // Color.value は deprecated なのでこれを使用
    return '0x${v.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  /// "0xAARRGGBB" / "#RRGGBB" / "AARRGGBB" から Color へ
  static Color colorFromHexString(String? hex, {String fallback = '0xFFD7F0FF'}) {
    if (hex == null || hex.isEmpty) hex = fallback;
    var s = hex.trim().toUpperCase();
    // "#RRGGBB" → "0xFFRRGGBB" に正規化
    if (s.startsWith('#')) {
      s = s.substring(1); // RRGGBB or AARRGGBB
      if (s.length == 6) s = 'FF$s';
      s = '0x$s';
    }
    // "RRGGBB" or "AARRGGBB" → "0x..." に正規化
    if (!s.startsWith('0X')) {
      if (s.length == 6) {s = '0xFF$s' ;}
      else {s = '0x$s';}
    }
    return Color(int.parse(s));
  }
}

