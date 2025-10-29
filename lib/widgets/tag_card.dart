import 'package:flutter/material.dart';

class TagCard extends StatelessWidget {

  final String name;
  final String updatedAt;

  const TagCard({
    super.key,
    required this.name,
    required this.updatedAt,
  });

  static const _dateStyle = TextStyle(fontSize: 8, color: Colors.blue);

  @override
  Widget build(BuildContext context) {

    // 1文字あたりの幅を決める（調整可能）
    const double baseWidth = 60;
    const double extraPerChar = 10;

    // 幅を計算
    final int length = text.length;
    final double width = length <= 3
        ? baseWidth
        : baseWidth + (length - 3) * extraPerChar;

    return SizedBox(
      width: width,
      height: 50,
      child: Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // 縦方向の揃え方
            children: [
              Text(
                name,
                style: const TextStyle(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}