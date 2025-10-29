import 'package:original_dict_app/models/card_entity.dart';
import 'package:original_dict_app/utils/db/time_helper.dart';

// 「DBの生データ → 安全な Dart のモデル」変換
class CardMapper {
  static CardEntity toEntity(Map<String, Object?> row) {
    final m = Map<String, dynamic>.from(row);

    // is_fave を 0/1 に正規化（bool / "true"/"1" も許容）
    final fav = m['is_fave'];
    if (fav is bool) {
      m['is_fave'] = fav ? 1 : 0;
    } else if (fav is String) {
      m['is_fave'] = (fav == '1' || fav.toLowerCase() == 'true') ? 1 : 0;
    }

    // created_at / updated_at が int(UNIX ms) なら ISO8601 へ

    m['created_at'] = TimeHelper.toIso(m['created_at'], required: true);
    if (m['updated_at'] != null) {
      m['updated_at'] = (m['updated_at'] is int)
          ? DateTime.fromMillisecondsSinceEpoch(m['updated_at'] as int).toIso8601String()
          : m['updated_at'];
    }

    return CardEntity.fromMap(m);
  }
}