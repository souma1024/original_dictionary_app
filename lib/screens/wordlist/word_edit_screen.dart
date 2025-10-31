import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WordEditScreen extends StatefulWidget {
  const WordEditScreen({super.key});

  @override
  State<WordEditScreen> createState() => _WordEditScreenState();
}

class _WordEditScreenState extends State<WordEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _introController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _introController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      // TODO: DB保存処理（後で実装）
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存しました')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('単語カード作成')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '単語名'),
                validator: (value) => value!.isEmpty ? '単語名を入力してください' : null,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'.*')), // 全角OK
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _introController,
                decoration: const InputDecoration(labelText: '説明'),
                maxLines: 3,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'.*')), // 全角OK
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('保存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
