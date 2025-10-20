import 'package:flutter/material.dart';
import 'package:original_dict_app/utils/db/text_length_helper.dart';

class WordCard extends StatelessWidget {

  final String name;
  final String intro;
  final String updatedAt;

  const WordCard({
    super.key,
    required this.name,
    required this.intro,
    required this.updatedAt,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 115,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1行目（タイトル＋右側に何か置きたいなら Row）
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 例えばお気に入りアイコンなど
                  // Icon(Icons.star, size: 16),
                ],
              ),
              const SizedBox(height: 4),

              // 2行目（イントロ＝本文）
              Expanded(
                child: Text(
                  TextLengthHelper.limitTextLength(intro),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // 右下に日付
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  updatedAt,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}