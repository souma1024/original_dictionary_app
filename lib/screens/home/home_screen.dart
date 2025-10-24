import 'package:flutter/material.dart';
import 'package:original_dict_app/widgets/common_drawer.dart';
import 'package:original_dict_app/screens/home/words_list_screen.dart';
import 'package:original_dict_app/utils/test/insert_sample_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('オリジナル辞書アプリ'),
      ),
      drawer:  CommonDrawer(),
      // SafeAreaを使うと、どんな端末でも安全にUIが表示される
      // 時刻などが書いてある画面最上部にはUIを設置しないようにするなど
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.pushNamed(context, '/add');
          // 今は仮
          //debugPrint('押したね？');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}