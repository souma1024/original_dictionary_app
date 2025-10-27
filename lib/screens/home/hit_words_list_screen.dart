import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:original_dict_app/dto/card_hit.dart';
import 'package:original_dict_app/repository/card_repository.dart';
import 'package:original_dict_app/widgets/word_card.dart';
import 'package:original_dict_app/widgets/search_box.dart';
import 'package:original_dict_app/controller/word_selection_scope.dart';
import 'package:original_dict_app/controller/word_collection_controller.dart';

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
  final _reload$ = PublishSubject<Object?>();

  @override
  void initState() {
    super.initState();
    _selection = WordSelectionController<int>();

    _hits$ = Rx.combineLatest2<String, Object?, String>(
      _query$
          .map((q) => q.trim())
          .debounceTime(const Duration(milliseconds: 300)),
      _reload$.startWith(null),                 // ← 起動時も一度発火させる
      (q, _) => q,                              // ← いつでも最新の検索語で再検索
    )
    // switchMapはDBからデータを取得し表示させている最中にインプットデータが変わった時、古いインプットデータでの処理結果表示をキャンセルする。
    .switchMap((q) => Stream.fromFuture(CardRepository.instance.listForDisplay(q)))
    .doOnData((hits) {
      if (_selection.selectionMode) {
        final visible = hits.map((h) => h.card.id).toSet();
        _selection.pruneNotVisible(visible);
      }
    })
    .shareReplay(maxSize: 1);  //直近1回の検索結果をキャッシュする
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

  Future<void> _deleteSelected() async {
    final ids = _selection.selectedIds.toList();
    if (ids.isEmpty) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('選択した単語を削除しますか？'),
        content: Text('合計 ${ids.length} 件を削除します。取り消せません。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('削除')),  //TextButton＝補助操作、FilledButton＝主要操作の強調ボタン
        ], 
      ),
    );

    if (ok == true) {
      // データを削除
      await CardRepository.instance.deleteCards(ids);
      // 選択解除
      _selection.exit();
      // ★ 同じクエリで再検索してUI更新
      _reload$.add(null); 
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('削除しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WordSelectionScope<int>( // ★ ここでスコープ化
      controller: _selection,
      child: Column(
        children: [
          AnimatedBuilder(       // ★ 選択状態の変化で再ビルド
            animation: _selection,  
            builder: (context, _) { //(_)は、引数は受けるが使わないよ！というサイン
              final inSelect = _selection.selectionMode;
              final count = _selection.count;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: inSelect
                    ? Row(
                        children: [
                          Text('$count 件選択中', style: Theme.of(context).textTheme.titleMedium),
                          const Spacer(), // 下のIconButtonらと上のTextを空きスペースを自動で広げるウィジェット
                          IconButton(
                            tooltip: '選択解除',
                            icon: const Icon(Icons.close),
                            onPressed: _selection.exit,
                          ),
                          IconButton(
                            tooltip: 'カードを削除',
                            icon: const Icon(Icons.delete),
                            onPressed: _deleteSelected,
                          ),
                        ],
                      )
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