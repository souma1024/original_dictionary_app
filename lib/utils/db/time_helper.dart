import 'package:intl/intl.dart';

class TimeHelper {
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('yyyy/MM/dd HH:mm');
    return formatter.format(dateTime);
  }

  static String toIso(dynamic v, {bool required = false}) {
    if (v == null) {
      if (required) {
        // created_at はモデル側で required なので最低限のフォールバック
        return DateTime.now().toIso8601String();
      }
      return DateTime.now().toIso8601String();
    }
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v).toIso8601String();
    if (v is String) return v; // すでに ISO とみなす
    return DateTime.now().toIso8601String();
  }
} 