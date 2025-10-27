import 'package:flutter/material.dart';
import 'package:original_dict_app/dto/card_hit.dart';
import 'package:original_dict_app/repository/card_repository.dart';
import 'package:original_dict_app/widgets/word_card.dart';
import 'package:original_dict_app/screens/common_scaffold.dart';

class WordListScreen extends StatelessWidget {
  const WordListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(  
      title: '単語一覧',  
      body: FutureBuilder<List<CardHit>>(
        future: CardRepository.instance.listForDisplay(""),
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
                  height: 115, // ← カードの高さを直接調整
                  child: WordCard(
                    id: word.card.id,
                    name: word.card.name,
                    limitedIntro: word.card.intro,
                    isFave: word.card.isFave,
                    updatedAt: word.card.updatedAtText,
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
