import 'package:flutter/material.dart';
import 'package:original_dict_app/widgets/common_drawer.dart';

class TagScreen extends StatelessWidget {
  const TagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            IconData(0xea53, fontFamily: 'MaterialIcons'), // 戻る用のボタン
          ),
          onPressed: () {
            Navigator.pop(context); // 押したら前の画面に戻る
          },
        ),
        title: const Text('タグ選択'),
        backgroundColor: Colors.green,
      

      actions:[
        TextButton(
          onPressed:_onSelectPressed,
          child: const Text('選択',
          style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
    ],
  ),
    
      body: Column(
        children: [
          const SizedBox(height: 50), // 画面中央より少し上に調整
          ElevatedButton(
            onPressed: _addTag,
            child: const Text('タグを追加'),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: tags.map((tag) {
                    return TagCard(
                      name: tag['name']!,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

      

      