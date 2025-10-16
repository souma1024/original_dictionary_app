import 'package:flutter/material.dart';
import './repository/card_repository.dart';
// import './data/app_database.dart'; // ここは直接使わないなら不要

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _nameCtrl = TextEditingController();
  final _introCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _introCtrl.dispose();
    super.dispose();
  }

  Future<void> _addCard(BuildContext ctx) async {
    final name = _nameCtrl.text.trim();
    final intro = _introCtrl.text.trim();
    if (name.isEmpty || intro.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('名前とコメントを入力してください')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final id = await CardRepository.instance.addCard(name: name, intro: intro);
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('保存しました（ID: $id）')),
      );
      _nameCtrl.clear();
      _introCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('保存に失敗しました: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder( // ← ここで MaterialApp/Scaffold 配下の context を作る
          builder: (ctx) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'カード名')),
                    const SizedBox(height: 12),
                    TextField(controller: _introCtrl, decoration: const InputDecoration(hintText: 'コメント')),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isSaving 
                        ? null  
                        : ()  async {
                          await _addCard(ctx);
                      }, // ← Builder の ctx を渡す
                      child: _isSaving
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('カード追加'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}