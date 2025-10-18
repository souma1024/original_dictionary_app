import 'package:flutter/material.dart';
import 'widgets/search_box.dart';
import 'widgets/word_card.dart';
import 'widgets/common_drawer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          // 画面ヘッダー(上部)
        appBar:AppBar(
          title: const Text('オリジナル辞書アプリ'),
          backgroundColor: Colors.lightBlue,
        ),

        // 画面のサイドバー（drawer） widgets/common_drawer.dartのコンポーネント
        drawer:  CommonDrawer(),
        
        // 画面のメインコンテント
        body: Padding(
          padding: const EdgeInsets.only(top: 80, left: 32, right: 32),
          child: Column(
            children: [
              const SearchBox(), //widgets/search_box.dart のコンポーネント
              const SizedBox(height: 16),
              
              //✅ 検索結果リスト（残りの高さを全部使う）
              Expanded(
                child: ListView.builder(
                  itemCount: 1, // ← 1個だけ表示するなら1
                  itemBuilder: (context, index) {
                    return const WordCard(   // widgets/word_card.dart のコンポーネント
                      name: 'りんご',
                      intro: 'くだもの',
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        //画面下部の追加ボタン（位置は後で修正する予定）
        floatingActionButton: FloatingActionButton(
          onPressed: () => {print("押したね？")},       
          child: const Icon(Icons.add)
        ),
      )
    );
  }
}
