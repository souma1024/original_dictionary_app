import 'package:flutter/material.dart';

// ここにWordDetailScreenのコードも書くか、別ファイルに分けてimportする

void main() {
  runApp(MaterialApp(
    home: WordDetailScreen(
      word: 'Flutter',
      tag: 'Framework',
      description: 'Googleが開発したUIツールキット。',
    ),
  ));
}

class WordDetailScreen extends StatelessWidget {
  final String word;
  final String tag;
  final String description;

  const WordDetailScreen({
    Key? key,
    required this.word,
    required this.tag,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('単語詳細')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(word, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('タグ: $tag', style: TextStyle(fontSize: 20, color: Colors.grey[700])),
            SizedBox(height: 16),
            Text('説明:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text(description, style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
