import 'package:flutter/material.dart';
import 'package:original_dict_app/models/card_entity.dart';
import 'package:original_dict_app/repository/card_repository.dart';
import 'package:original_dict_app/widgets/word_card.dart';
import 'package:original_dict_app/utils/db/time_helper.dart';
import 'package:original_dict_app/widgets/common_drawer.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  int _currentPage = 1;
  final int _limit = 10;
  late Future<int> _totalCardsFuture;

  @override
  void initState() {
    super.initState();
    _totalCardsFuture = CardRepository.instance.getCardCount();
  }

  Future<List<CardEntity>> _loadCards() {
    return CardRepository.instance.getCardsByPage(
      page: _currentPage,
      limit: _limit,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('単語一覧'),
      ),
      drawer: const CommonDrawer(),
      body: FutureBuilder<int>(
        future: _totalCardsFuture,
        builder: (context, countSnapshot) {
          if (!countSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalCards = countSnapshot.data!;
          final totalPages = (totalCards / _limit).ceil();

          return Column(
            children: [
              Expanded(
                child: FutureBuilder<List<CardEntity>>(
                  future: _loadCards(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('エラーが発生しました'));
                    }
                    final words = snapshot.data ?? [];

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
                            height: 110,
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
              ),

              // ===== ページングボタン =====
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 前へ
                    ElevatedButton(
                      onPressed: _currentPage > 1
                          ? () {
                        setState(() {
                          _currentPage--;
                        });
                      }
                          : null,
                      child: const Text('◀ 前へ'),
                    ),
                    const SizedBox(width: 16),
                    Text('$_currentPage / $totalPages ページ'),
                    const SizedBox(width: 16),
                    // 次へ
                    ElevatedButton(
                      onPressed: _currentPage < totalPages
                          ? () {
                        setState(() {
                          _currentPage++;
                        });
                      }
                          : null,
                      child: const Text('次へ ▶'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
