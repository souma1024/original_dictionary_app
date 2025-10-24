import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:original_dict_app/dto/card_hit.dart';
import 'package:original_dict_app/repository/card_repository.dart';
import 'package:original_dict_app/widgets/word_card.dart';
import 'package:original_dict_app/widgets/search_box.dart';
import 'package:original_dict_app/utils/db/time_helper.dart';

class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
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
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final hits = snapshot.data!;
              if (hits.isEmpty) {
                return const Center(child: Text('該当する単語がありません'));
              }

              return ListView.builder(
                itemCount: hits.length,
                itemBuilder: (context, index) {
                  final h = hits[index];
                  return RepaintBoundary( // 各カードの再描画を分離
                    child: WordCard(
                      name: h.card.name,
                      intro: h.card.intro,
                      updatedAt: TimeHelper.formatDateTime(h.card.updatedAt),
                    ),
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