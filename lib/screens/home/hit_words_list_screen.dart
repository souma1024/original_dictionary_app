import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:original_dict_app/dto/card_hit.dart';
import 'package:original_dict_app/repository/card_repository.dart';
import 'package:original_dict_app/widgets/word_card.dart';
import 'package:original_dict_app/widgets/search_box.dart';

class HitWordsListScreen extends StatefulWidget {
  const HitWordsListScreen({super.key});

  @override
  State<HitWordsListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<HitWordsListScreen> {
  // 検索語を流すためのSubject
  final _query$ = BehaviorSubject<String>.seeded('');

  late final Stream<List<CardHit>> _hits$;

  @override
  void initState() {
    super.initState();

    _hits$ = _query$
        .map((q) => q.trim())
        .distinct()
        .debounceTime(const Duration(milliseconds: 250))
        // 最新検索のみ有効。前の重いクエリは破棄される
        .switchMap((q) => Stream.fromFuture(CardRepository.instance.listForDisplay(q)))
        .shareReplay(maxSize: 1); // 最新値を保持（再ビルド時に有効）
  }

  @override
  void dispose() {
    _query$.close();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _query$.add(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBox(onChanged: _onSearchChanged),
        Expanded(
          child: StreamBuilder<List<CardHit>>(
            stream: _hits$,
            initialData: const [], // 初回は空表示
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
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, // スクロールでキーボード閉じる
                    itemExtent: 115,  //カードの高さ
                    itemCount: hits.length,
                    itemBuilder: (context, index) {
                      final h = hits[index];
                      return RepaintBoundary( // 各カードの再描画を分離
                        child: WordCard(
                          key: ValueKey(h.card.id), //キーを持たせることで、単語カードを識別
                          name: h.card.name,
                          limitedIntro: h.card.intro,
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
    );
  }
}