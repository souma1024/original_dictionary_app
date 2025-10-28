import 'package:flutter/material.dart';
import 'package:original_dict_app/dto/card_hit.dart';
import 'package:original_dict_app/repository/card_repository.dart';
import 'package:original_dict_app/widgets/word_card.dart';
import 'package:original_dict_app/screens/common_scaffold.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final repo = CardRepository.instance;
  final int limit = 10;

  int _page = 0;
  int _total = 0;
  List<CardHit> _cards = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final count = await repo.getCardCount();
    final offset = _page * limit;
    final rows = await repo.getCardsAsHits(limit: limit, offset: offset);

    if (mounted) {
      setState(() {
        _cards = rows;
        _total = count;
        _isLoading = false;
      });
    }
  }

  void _nextPage() {
    if ((_page + 1) * limit >= _total) return;
    setState(() => _page++);
    _loadPage();
  }

  void _prevPage() {
    if (_page == 0) return;
    setState(() => _page--);
    _loadPage();
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_total / limit).ceil().clamp(1, 9999);
    final currentPage = _page + 1;

    return CommonScaffold(
      title: '単語一覧',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
          ? const Center(child: Text('登録された単語がありません'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final word = _cards[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: SizedBox(
                    height: 115,
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
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _page > 0 ? _prevPage : null,
                  child: const Text('<< 前へ'),
                ),
                Text('$currentPage / $totalPages'),
                TextButton(
                  onPressed: (_page + 1) * limit < _total ? _nextPage : null,
                  child: const Text('次へ >>'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
