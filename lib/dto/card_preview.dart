import 'package:original_dict_app/utils/db/time_helper.dart';
import 'package:original_dict_app/utils/db/text_length_helper.dart';

class CardPreview {
  final int id;
  final String name;
  final String intro;
  final bool isFave;
  final String updatedAtText;

  CardPreview({
    required this.id,
    required this.name,
    required this.intro,
    required this.isFave,
    required this.updatedAtText,
  });

  factory CardPreview.fromMap(Map<String, dynamic> m) {
    return CardPreview(
      id: m['id'] as int,
      name: m['name'] as String,
      intro: limitTextLength(m['intro'] as String),
      isFave: m['is_fave'] == 1,
      updatedAtText: TimeHelper.formatDateTime(DateTime.parse(m['updated_at'] as String))
    );
  }
}