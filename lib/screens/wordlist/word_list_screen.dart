import 'package:flutter/material.dart';
import 'package:original_dict_app/dto/card_hit.dart';
import 'package:original_dict_app/repository/card_repository.dart';
import 'package:original_dict_app/widgets/word_card.dart';
import 'package:original_dict_app/screens/common_scaffold.dart';
import 'package:original_dict_app/controller/word_selection_controller.dart';
import 'package:original_dict_app/utils/delete_cards_utils.dart';
import 'package:original_dict_app/widgets/confirm_delete_cards_dialog.dart';
import 'package:original_dict_app/controller/word_selection_scope.dart';
import 'package:original_dict_app/widgets/selection_toolbar.dart';

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

  late final WordSelectionController<int> _selection;
  late final DeleteCardsUtils _deleteCards;

  @override
  void initState() {
    super.initState();
    _selection = WordSelectionController<int>();
    _deleteCards = DeleteCardsUtils(
      repo: repo,
      selection: _selection,
      onReload: _reloadCurrentPage,
    );
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
    // 選択モード中なら「画面に見えていないID」を選択から除去
    if (_selection.selectionMode) {
      final visible = rows.map((h) => h.card.id).toSet();
      _selection.pruneNotVisible(visible);
    }
  }

  void _nextPage() {
    if ((_page + 1) * limit >= _total) return;
    setState(() => _page++);
    _loadPage();
  }

  Future<void> _reloadCurrentPage() async {
    await _loadPage();
  }

  void _prevPage() {
    if (_page == 0) return;
    setState(() => _page--);
    _loadPage();
  }

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  Future<void> _handleDeletePressed() async {
    final ids = _selection.selectedIds.toList();
    if (ids.isEmpty) return;

    final ok = await confirmDeleteCardsDialog(context, ids.length);
    if (ok != true) return;

    await _deleteCards(ids); // repo.delete → selection.exit → onReload(_reloadCurrentPage)
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('削除しました')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_total / limit).ceil().clamp(1, 9999);
    final currentPage = _page + 1;

    return WordSelectionScope<int>(
      controller: _selection,
      child:  CommonScaffold(
        title: '単語一覧',
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _cards.isEmpty
              ? const Center(child: Text('登録された単語がありません'))
              : Column(
                children: [
                  // 選択モード時だけツールバーを表示
                  ValueListenableBuilder<bool>(
                    valueListenable: _selection.selectionModeListenable,
                    builder: (context, inSelect, _) {
                      if (!inSelect) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: SelectionToolbar(
                          selection: _selection,
                          onDeletePressed: _handleDeletePressed,
                          onExitPressed: _selection.exit,
                        ),
                      );
                    },
                  ),
                  // 本体リスト
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

                  // ページャ
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
      ),
    );
  }
}
