import 'package:flutter/material.dart';

// drawerはハンバーガーメニューを押すと出てくるサイドバーのこと
class CommonDrawer extends StatelessWidget {
  const CommonDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final current = ModalRoute.of(context)?.settings.name;

    void go(String routeName) {
      // 既に同じ画面なら閉じるだけ
      if (current == routeName) {
        Navigator.pop(context);
        return;
      }
      Navigator.pop(context); // 先に Drawer を閉じる
      Navigator.pushReplacementNamed(context, routeName);
    }

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(child: Text('Drawer Header')),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('ホーム'),
            onTap: () => go('/home')
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('単語一覧'),
            onTap: () => go('/words')
          ),
          ListTile(
            leading: Icon(Icons.tag),
            title: Text('タグ管理'),
          ),
          ListTile(
            leading: Icon(Icons.question_answer),
            title: Text('クイズ'),
            onTap: () => go('/quiz')
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