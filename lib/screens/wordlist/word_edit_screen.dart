import 'package:flutter/material.dart';
import 'package:original_dict_app/models/card_entity.dart';
import 'package:original_dict_app/repository/card_repository.dart';
import 'package:original_dict_app/utils/security/input_sanitizer.dart';

class WordEditScreen extends StatefulWidget {
  const WordEditScreen({super.key});

  @override
  State<WordEditScreen> createState() => _WordEditScreenState();
}

class _WordEditScreenState extends State<WordEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _introController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _introController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // 入力値をサニタイズ
      final name = InputSanitizer.sanitizeSimple(_nameController.text.trim());
      final intro = InputSanitizer.sanitizeSimple(_introController.text.trim());

      final newCard = CardEntity(
        id: null, // DBが採番
        name: name,
        nameHira: '', // transliterate側で設定される
        intro: intro,
        introHira: '',
        isFave: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await CardRepository.instance.insertCard(newCard);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('カードを保存しました')),
        );
        Navigator.pop(context, true); // true: 成功を呼び出し元へ返す
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存中にエラーが発生しました: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新しい単語カード'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '単語',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '単語を入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _introController,
                decoration: const InputDecoration(
                  labelText: '説明・意味',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 5,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isSaving
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? '保存中...' : '保存'),
                  onPressed: _isSaving ? null : _saveCard,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
