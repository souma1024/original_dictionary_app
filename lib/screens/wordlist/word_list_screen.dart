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
import 'package:original_dict_app/repository/card_tag_repository.dart';
import 'package:original_dict_app/models/tag_entity.dart';

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
  Map<int, List<TagEntity>> _tagMap = {};
  bool _isLoading = false;
  String _orderBy = 'updated_at DESC, id DESC'; // ✅ 並び順
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
    final rows = await repo.getCardsAsHits(limit: limit, offset: offset, orderBy: _orderBy);

    final ids = rows.map((h) => h.card.id).toList();

    final tagMap = ids.isEmpty
      ? <int, List<TagEntity>>{}
      : await CardTagRepository.instance.getTagsByCardIds(ids);

    if (mounted) {
      setState(() {
        _cards = rows;
        _total = count;
         _tagMap = tagMap;
        _isLoading = false;
      });
    }

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

  void _prevPage() {
    if (_page == 0) return;
    setState(() => _page--);
    _loadPage();
  }

  Future<void> _reloadCurrentPage() async {
    await _loadPage();
  }

  void _changeOrder(String newOrder) {
    setState(() {
      _orderBy = newOrder;
      _page = 0;
    });
    _loadPage();
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
      child: CommonScaffold(
        title: '単語一覧',
        body: Column(
          children: [
            // ✅ 並び替えボタン
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _changeOrder('updated_at DESC, id DESC'),
                    child: const Text('更新日順'),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _changeOrder('updated_at DESC, id DESC'),
                          child: const Text('更新日順'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _changeOrder('name_hira COLLATE NOCASE ASC'),
                          child: const Text('名前順'),
                        ),
                      ],
                    ),
                  ),
                  // 本体リスト
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      itemCount: _cards.length,
                      itemExtent: 115,
                      itemBuilder: (context, index) {
                        final word = _cards[index];
                        final tags = _tagMap[word.card.id] ?? const <TagEntity>[];
                        return SizedBox(
                            child: WordCard(
                              id: word.card.id,
                              name: word.card.name,
                              limitedIntro: word.card.intro,
                              isFave: word.card.isFave,
                              updatedAt: word.card.updatedAtText,
                              tagList: tags, // ★ 左下にミニタグ表示
                              onTagTap: (t) async {
                                // 例: タグでフィルタ画面へ遷移 or 検索へ反映など
                              },
                              onNeedReload: () async {
                                final currentContext = context;
                                await _reloadCurrentPage();
                                if (!mounted) return;
                                ScaffoldMessenger.of(currentContext).showSnackBar(
                                  const SnackBar(content: Text('変更を保存しました')),
                                );
                              },
                            ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _cards.isEmpty
                  ? const Center(child: Text('登録された単語がありません'))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _cards.length,
                itemExtent: 115,
                itemBuilder: (context, index) {
                  final word = _cards[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: WordCard(
                      id: word.card.id,
                      name: word.card.name,
                      limitedIntro: word.card.intro,
                      isFave: word.card.isFave,
                      updatedAt: word.card.updatedAtText,
                    ),
                  );
                },
              ),
            ),

            // ✅ ページャ
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

// import 'package:flutter/material.dart';
// import 'package:original_dict_app/dto/card_hit.dart';
// import 'package:original_dict_app/repository/card_repository.dart';
// import 'package:original_dict_app/widgets/word_card.dart';
// import 'package:original_dict_app/screens/common_scaffold.dart';
// import 'package:original_dict_app/controller/word_selection_controller.dart';
// import 'package:original_dict_app/utils/delete_cards_utils.dart';
// import 'package:original_dict_app/widgets/confirm_delete_cards_dialog.dart';
// import 'package:original_dict_app/controller/word_selection_scope.dart';
// import 'package:original_dict_app/widgets/selection_toolbar.dart';
// import 'package:original_dict_app/repository/card_tag_repository.dart';
// import 'package:original_dict_app/models/tag_entity.dart';

// class WordListScreen extends StatefulWidget {
//   const WordListScreen({super.key});

//   @override
//   State<WordListScreen> createState() => _WordListScreenState();
// }

// class _WordListScreenState extends State<WordListScreen> {
//   final repo = CardRepository.instance;
//   final int limit = 10;

//   int _page = 0;
//   int _total = 0;
//   List<CardHit> _cards = [];
//   Map<int, List<TagEntity>> _tagMap = {};
//   bool _isLoading = false;

//   String _orderBy = 'updated_at DESC, id DESC'; // ✅ 並び順

//   late final WordSelectionController<int> _selection;
//   late final DeleteCardsUtils _deleteCards;

//   @override
//   void initState() {
//     super.initState();
//     _selection = WordSelectionController<int>();
//     _deleteCards = DeleteCardsUtils(
//       repo: repo,
//       selection: _selection,
//       onReload: _reloadCurrentPage,
//     );
//     _loadPage();
//   }

//   Future<void> _loadPage() async {
//     if (_isLoading) return;
//     setState(() => _isLoading = true);

//     final count = await repo.getCardCount();
//     final offset = _page * limit;
//     final rows = await repo.getCardsAsHits(
//       limit: limit,
//       offset: offset,
//       orderBy: _orderBy,
//     );

//     final ids = rows.map((h) => h.card.id).toList();

//     final tagMap = ids.isEmpty
//       ? <int, List<TagEntity>>{}
//       : await CardTagRepository.instance.getTagsByCardIds(ids);

//     if (mounted) {
//       setState(() {
//         _cards = rows;
//         _total = count;
//          _tagMap = tagMap;
//         _isLoading = false;
//       });
//     }

//     if (_selection.selectionMode) {
//       final visible = rows.map((h) => h.card.id).toSet();
//       _selection.pruneNotVisible(visible);
//     }
//   }

//   void _nextPage() {
//     if ((_page + 1) * limit >= _total) return;
//     setState(() => _page++);
//     _loadPage();
//   }

//   void _prevPage() {
//     if (_page == 0) return;
//     setState(() => _page--);
//     _loadPage();
//   }

//   Future<void> _reloadCurrentPage() async {
//     await _loadPage();
//   }

//   void _changeOrder(String newOrder) {
//     setState(() {
//       _orderBy = newOrder;
//       _page = 0;
//     });
//     _loadPage();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final totalPages = (_total / limit).ceil().clamp(1, 9999);
//     final currentPage = _page + 1;

//     return WordSelectionScope<int>(
//       controller: _selection,
//       child: CommonScaffold(
//         title: '単語一覧',
//         body: Column(
//           children: [
//             // ✅ 並び替えボタン
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton(
//                     onPressed: () => _changeOrder('updated_at DESC, id DESC'),
//                     child: const Text('更新日順'),
//                   ),
//                   const SizedBox(width: 8),
//                   ElevatedButton(
//                     onPressed: () => _changeOrder('name_hira COLLATE NOCASE ASC'),
//                     child: const Text('名前順'),
//                   ),
//                 ],
//               ),
//             ),

//             Expanded(
//               child: _isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : _cards.isEmpty
//                   ? const Center(child: Text('登録された単語がありません'))
//                   : ListView.builder(
//                 padding: const EdgeInsets.symmetric(vertical: 8),
//                 itemCount: _cards.length,
//                 itemExtent: 115,
//                 itemBuilder: (context, index) {
//                   final word = _cards[index];
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     child: WordCard(
//                       id: word.card.id,
//                       name: word.card.name,
//                       limitedIntro: word.card.intro,
//                       isFave: word.card.isFave,
//                       updatedAt: word.card.updatedAtText,
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // ✅ ページャ
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   TextButton(
//                     onPressed: _page > 0 ? _prevPage : null,
//                     child: const Text('<< 前へ'),
//                   ),
//                   Text('$currentPage / $totalPages'),
//                   TextButton(
//                     onPressed: (_page + 1) * limit < _total ? _nextPage : null,
//                     child: const Text('次へ >>'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
