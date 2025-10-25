import 'package:flutter/material.dart';

// drawerはハンバーガーメニューを押すと出てくるサイドバーのこと
class CommonDrawer extends StatelessWidget {
  const CommonDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children:  [
          DrawerHeader(child: Text('Drawer Header')),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('ホーム'),
            onTap: () {
              Navigator.pop(context); // Drawerを閉じる
              Future.delayed(const Duration(milliseconds: 250), () {
                Navigator.pushReplacementNamed(context, '/'); // ルート名でHomeに遷移
              });
              },
              ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('単語一覧'),
            onTap: () {
              Navigator.pop(context);  // Drawerを閉じる
              Navigator.pushReplacementNamed(context, '/words');  // ルート名で遷移
            },
          ),
          ListTile(
            leading: Icon(Icons.tag),
            title: Text('タグ一覧'),
          ),
          ListTile(
            leading: Icon(Icons.question_answer),
            title: Text('クイズ'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('設定'),
          ),
        ],
      ),
    );
  }
}