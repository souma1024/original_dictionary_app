import 'package:flutter/material.dart';

class CommonDrawer extends StatelessWidget {
  const CommonDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: const [
          DrawerHeader(child: Text('Drawer Header')),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('ホーム'),
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