import 'package:flutter/material.dart';
import 'package:original_dict_app/screens/home/words_list_screen.dart';
import 'package:original_dict_app/utils/test/insert_sample_data.dart';
import 'package:original_dict_app/screens/common_scafforld.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: "ホーム",
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children:  [
            SizedBox(height: 16),
            // 検索結果リスト（残りの高さを全部使う）
            Expanded(child: WordListScreen()),
            ElevatedButton(  //これはテスト用、本番はボタンごと消す。
              onPressed: () async {
                await insertSampleData();
              },
              child: Text('サンプルデータ投入'),
            ),
          ],
        ),
      ),
      fab: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}