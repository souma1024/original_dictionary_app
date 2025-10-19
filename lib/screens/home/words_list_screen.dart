import 'package:original_dict_app/models/card_entity.dart';
import 'package:original_dict_app/repository/card_repository.dart';
import 'package:original_dict_app/widgets/word_card.dart';
import 'package:flutter/material.dart';

class WordListScreen extends StatelessWidget {

  const WordListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CardEntity>>(
      future: CardRepository.instance.getCards(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('エラーが発生しました'));
        }

        final words = snapshot.data ?? [];

        return ListView.builder(
          itemCount: words.length,
          itemBuilder: (context, index) {
            final word = words[index];
            return WordCard(
              name: word.name,
              intro: word.intro,
            );
          },
        );
      },
    );
  }
}