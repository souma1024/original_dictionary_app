import 'package:original_dict_app/dto/card_hit.dart';
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
  // late: 非nullだがinitStateで後から必ず代入する前提
  late Future<List<CardHit>> _future;

  @override
  void initState() {
    super.initState();
    _future = CardRepository.instance.listForDisplay('');
  }

  void _onSearchChanged(String value) {
    final query = value.trim();

    // クエリに応じて Future を準備
    final future = CardRepository.instance.listForDisplay(query);

    // 状態更新（await の後にまとめて）
    setState(() {
      _future = future;
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
          child: FutureBuilder<List<CardHit>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('エラー: ${snapshot.error}'));
              }

              final hits = snapshot.data ?? const [];
              if (hits.isEmpty) {
                return const Center(child: Text('該当する単語がありません'));
              }

              return ListView.builder(
                itemCount: hits.length,
                itemBuilder: (context, index) {
                  final h = hits[index];
                  return WordCard(
                    name: h.card.name,
                    intro: h.card.intro,
                    updatedAt: TimeHelper.formatDateTime(h.card.updatedAt),
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