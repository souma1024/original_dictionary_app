import 'package:flutter/material.dart';
import 'package:original_dict_app/screens/home/hit_words_list_screen.dart';
import 'package:original_dict_app/utils/test/insert_sample_data.dart';
import 'package:original_dict_app/screens/wordlist/word_edit_screen.dart';
import 'package:original_dict_app/screens/common_scaffold.dart';

class HomeScreen extends StatelessWidget {
  final _hitWordsListKey = GlobalKey<HitWordsListScreenState>();
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: "ホーム",
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children:  [
            SizedBox(height: 4.0),
            // 検索結果リスト（残りの高さを全部使う）
            Expanded(child: HitWordsListScreen(key: _hitWordsListKey)),
            // ElevatedButton(  //これはテスト用、本番はボタンごと消す。
            //   onPressed: () async {
            //     await insertSampleData();   // カードとタグを先に挿入
            //     await attachRandomTags();   // ランダムタグ付与を実行！
            //     _hitWordsListKey.currentState?.reload();
            //   },
            //   child: Text('サンプルデータ投入'),
            // ),
          ],
        ),
      ),
      fab: FloatingActionButton(
        onPressed: () async {
          final changed = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WordEditScreen()),
          );

          if (!context.mounted) return;

          if (changed == true) {
            // カードを追加後にリストを再読み込み
            _hitWordsListKey.currentState?.reload(); 
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}