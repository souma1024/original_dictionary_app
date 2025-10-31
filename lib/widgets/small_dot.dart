import 'package:flutter/material.dart';
import 'package:original_dict_app/utils/color_util.dart';

/// 左側の小さい丸
class SmallDot extends StatelessWidget {
  final Color color;
  final double size;
  final double rightMargin;

  const SmallDot({
    super.key, 
    required this.color,
    this.size = 6, 
    this.rightMargin = 4, 
  });

  factory SmallDot.fromHex(String? hex) {
    return SmallDot(color: ColorUtil.fromAny(hex));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: EdgeInsets.only(right: rightMargin),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

