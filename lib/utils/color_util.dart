import 'package:flutter/material.dart';
import 'dart:math';

class ColorUtil {
  static Color fromAny(String? input, {Color fallback = const Color(0xFFE7F2F9)}) {
    if (input == null || input.trim().isEmpty) return fallback;
    String s = input.trim().toLowerCase();

    // rgb(r,g,b)
    if (s.startsWith('rgb')) {
      final nums = s.replaceAll(RegExp(r'[^0-9,]'), '').split(',');
      if (nums.length == 3) {
        final r = int.parse(nums[0]);
        final g = int.parse(nums[1]);
        final b = int.parse(nums[2]);
        return Color.fromARGB(255, r, g, b);
      }
      return fallback;
    }

    // 先頭の # / 0x を除去
    if (s.startsWith('0x')) s = s.substring(2);
    if (s.startsWith('#')) s = s.substring(1);

    // 6桁なら先頭にFF（不透明）を付与、8桁ならそのまま
    if (s.length == 6) {
      s = 'ff$s';
    } else if (s.length != 8) {
      return fallback; // 想定外はフォールバック
    }

    try {
      final value = int.parse(s, radix: 16);
      return Color(value);
    } catch (_) {
      return fallback;
    }
  }

  static String _randomPastelHex() {
    final rnd = Random();
    final r = 127 + rnd.nextInt(128);
    final g = 127 + rnd.nextInt(128);
    final b = 127 + rnd.nextInt(128);
    return '${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }

  static String nameToColorHex(String name) {
    if (name.isEmpty) {
      return '#${_randomPastelHex()}'; // 空文字なら完全ランダム
    }

    // 名前のハッシュ値を種にして擬似乱数を生成
    final hash = name.hashCode;
    final rnd = Random(hash);

    // パステル寄りにするため RGB を 127〜255 の範囲で生成
    final r = 127 + rnd.nextInt(128);
    final g = 127 + rnd.nextInt(128);
    final b = 127 + rnd.nextInt(128);

    // #RRGGBB 形式で返す
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }  
}
