import 'package:flutter/material.dart';
import 'package:original_dict_app/models/card_entity.dart';
import 'package:original_dict_app/repository/card_repository.dart';
import 'package:original_dict_app/widgets/word_card.dart';
import 'package:original_dict_app/utils/db/time_helper.dart';
import 'package:original_dict_app/widgets/common_drawer.dart';

class WordListScreen extends StatelessWidget {
  const WordListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('単語一覧'),
      ),
      drawer: const CommonDrawer(),
      body: FutureBuilder<List<CardEntity>>(
        future: CardRepository.instance.getCards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('エラーが発生しました'));
          }

          final words = (snapshot.data ?? []).take(10).toList();

          if (words.isEmpty) {
            return const Center(child: Text('登録された単語がありません'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: words.length,
            itemBuilder: (context, index) {
              final word = words[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: SizedBox(
                  height: 110, // ← カードの高さを直接調整
                  child: WordCard(
                    name: word.name,
                    intro: word.intro,
                    updatedAt: TimeHelper.formatDateTime(word.updatedAt),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
