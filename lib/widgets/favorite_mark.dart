import 'package:flutter/material.dart';

// お気に入りボタン
class FavoriteMark extends StatelessWidget {
  final bool isFave;
  final Color backgroundColor;
  const FavoriteMark({super.key, required this.isFave, required this.backgroundColor});
  

  @override
  Widget build(BuildContext context) {
    final fav = isFave;
    return CircleAvatar(
      radius: 12,
      backgroundColor: backgroundColor,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.star_border,  // ★枠線だけ
            size: 24,
            color: isFave ? Colors.yellow.shade700 : Colors.grey,
          ),
          Icon(
            Icons.star,        // ★塗りつぶし
            size: 20,          // 少し小さくして枠線を見せる
            color: fav ? Colors.yellow : Colors.transparent,
          ),
        ],
      ),
    );
  }
}