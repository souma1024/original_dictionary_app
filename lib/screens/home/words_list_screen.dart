import 'package:original_dict_app/models/card_entity.dart';
import 'package:original_dict_app/repository/card_repository.dart';
import 'package:original_dict_app/widgets/word_card.dart';
import 'package:original_dict_app/widgets/search_box.dart';
import 'package:original_dict_app/utils/db/time_helper.dart';
import 'package:flutter/material.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  String _query = '';
  // late: 非nullだがinitStateで後から必ず代入する前提
  late Future<List<CardEntity>> _future;

  @override
  void initState() {
    super.initState();
    _future = CardRepository.instance.getCards();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value.trim();
      _future = _query.isEmpty
          ? CardRepository.instance.getCards()
          : CardRepository.instance.searchByNameContains(_query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔍 検索バー
        SearchBox(
          onChanged: _onSearchChanged, // ← ここを紐づける
        ),
        Expanded(
          child: FutureBuilder<List<CardEntity>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('エラーが発生しました'));
              }

              final words = snapshot.data ?? [];
              if (words.isEmpty) {
                return const Center(child: Text('該当する単語がありません'));
              }

              return ListView.builder(
                itemCount: words.length,
                itemBuilder: (context, index) {
                  final word = words[index];
                  return WordCard(
                    name: word.name,
                    intro: word.intro,
                    updatedAt: TimeHelper.formatDateTime(word.updatedAt),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}