import 'package:flutter/material.dart';

class WordCard extends StatelessWidget {

  final String name;
  final String limitedIntro;
  final String updatedAt;

  const WordCard({
    super.key,
    required this.name,
    required this.limitedIntro,
    required this.updatedAt,
  });

  static const _dateStyle = TextStyle(fontSize: 12, color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 115,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 1,
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
              const SizedBox(height: 6),
              // 2行目（イントロ＝本文）
              Expanded(
                child: Text(
                  limitedIntro,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // 右下に日付
              Align(
                alignment: Alignment.bottomRight,
                child: Text(updatedAt, style: _dateStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}