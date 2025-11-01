import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:original_dict_app/dto/card_hit.dart';
import 'package:original_dict_app/repository/card_repository.dart';
import 'package:original_dict_app/widgets/word_card.dart';
import 'package:original_dict_app/widgets/search_box.dart';
import 'package:original_dict_app/controller/word_selection_scope.dart';
import 'package:original_dict_app/controller/word_selection_controller.dart';
import 'package:original_dict_app/utils/delete_cards_utils.dart';
import 'package:original_dict_app/widgets/confirm_delete_cards_dialog.dart';
import 'package:original_dict_app/widgets/selection_toolbar.dart';

class HitWordsListScreen extends StatefulWidget {
  const HitWordsListScreen({super.key});

  @override
  State<HitWordsListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<HitWordsListScreen> {
  // 検索語を流すためのSubject
  final _query$ = BehaviorSubject<String>.seeded('');

  late final Stream<List<CardHit>> _hits$;
  late final WordSelectionController<int> _selection;
  late final DeleteCardsUtils _deleteCards;
  final _reload$ = PublishSubject<Object?>();

  @override
  void initState() {
    super.initState();
    _selection = WordSelectionController<int>();
    final repo = CardRepository.instance;
    _deleteCards = DeleteCardsUtils(
      repo: repo,
      selection: _selection,
      onReload: () => _reload$.add(null),
    );

    _hits$ = Rx.combineLatest2<String, Object?, String>(
      _query$
        .map((q) => q.trim())
        .debounceTime(const Duration(milliseconds: 300)),
        _reload$,                 // ← 起動時も一度発火させる
        (q, _) => q,                              // ← いつでも最新の検索語で再検索
    )
    // switchMapはDBからデータを取得し表示させている最中にインプットデータが変わった時、古いインプットデータでの処理結果表示をキャンセルする。
    .switchMap((q) => Stream.fromFuture(repo.listForDisplay(q, limit: 5)))
    .doOnData((hits) {
      if (_selection.selectionMode) {
        final visible = hits.map((h) => h.card.id).toSet();
        _selection.pruneNotVisible(visible);
      }
    })
    .shareReplay(maxSize: 1);  //直近1回の検索結果をキャッシュする

    // 初回は1フレーム後に発火（UIを先に表示してからロード）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_reload$.isClosed) _reload$.add(null);
    });
  }

  @override
  void dispose() {
    _selection.dispose();
    _query$.close();
    _reload$.close();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _query$.add(value);
  }

  Future<void> _handleDeletePressed() async {
    try {
      final ids = _selection.selectedIds.toList();
      if (ids.isEmpty) return;
      final ok = await confirmDeleteCardsDialog(context, ids.length);
      if (ok != true) return;

      await _deleteCards(ids);   // call演算子でOK
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('削除しました')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('削除に失敗しました: $e')),
        );
      }
    } 
  }

  @override
  Widget build(BuildContext context) {
    return WordSelectionScope<int>( // ★ ここでスコープ化
      controller: _selection,
      child: Column(
        children: [
          ValueListenableBuilder<bool>(       // ★ 選択状態の変化で再ビルド
            valueListenable: _selection.selectionModeListenable,
            builder: (context, inSelect, _) { //(_)は、引数は受けるが使わないよ！というサイン
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: inSelect
                    ? SelectionToolbar(selection: _selection, onDeletePressed: _handleDeletePressed, onExitPressed: _selection.exit)
                    : SearchBox(onChanged: _onSearchChanged),
              );
            },
          ),
          // 本体
          Expanded(
            child: StreamBuilder<List<CardHit>>(
              stream: _hits$,
              initialData: const [],
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('読み込みに失敗しました: ${snapshot.error}'));
                }

                final hits = snapshot.data ?? const [];
                final isLoading = snapshot.connectionState == ConnectionState.waiting;

                if (hits.isEmpty && !isLoading) {
                  return const Center(child: Text('該当する単語がありません'));
                }

                return Stack(
                  children: [
                    ListView.builder(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      itemExtent: 115,
                      itemCount: hits.length,
                      addAutomaticKeepAlives: false, // ← 見切れたセルの保持をやめる
                      cacheExtent: 200,              // ← 先読みを控えめに（必要に応じて調整）
                      itemBuilder: (context, index) {
                        final h = hits[index];
                        return RepaintBoundary(
                          child: WordCard(
                            key: ValueKey(h.card.id),
                            id: h.card.id,              // ★ これが「表示中の集合」の要素
                            name: h.card.name,
                            limitedIntro: h.card.intro,
                            isFave: h.card.isFave,
                            updatedAt: h.card.updatedAtText,
                          ),
                        );
                      },
                    ),
                    if (isLoading)
                      const Align(
                        alignment: Alignment.topCenter,
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}