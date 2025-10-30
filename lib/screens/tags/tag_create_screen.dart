import 'package:flutter/material.dart';
import 'package:original_dict_app/repository/tag_repository.dart';
import 'package:original_dict_app/models/tag_entity.dart';
import 'package:sqflite/sqflite.dart';


class TagCreateScreen extends StatefulWidget {
  const TagCreateScreen({super.key});

  @override
  State<TagCreateScreen> createState() => _TagCreateScreenState();
}

class _TagCreateScreenState extends State<TagCreateScreen> {
  final _repo = TagRepository.instance;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final tag = TagEntity(id: null, name: _nameCtrl.text.trim(), createdAt: now, updatedAt: now);
      final newId = await _repo.insertTag(tag);
      final created = TagEntity(id: newId, name: tag.name, createdAt: tag.createdAt, updatedAt: tag.updatedAt);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('作成しました')));
      Navigator.of(context).pop<TagEntity>(created);
    } on DatabaseException catch (e) {
      final msg = e.toString().contains('UNIQUE')
        ? '同名のタグが既にあります'
        : '作成に失敗しました: ${e.toString()}';
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('作成に失敗しました: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('タグを作成')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'タグ名',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return 'タグ名を入力してください';
                  if (s.length > 64) return '64文字以内で入力してください';
                  return null;
                },
                onFieldSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save),
                label: _saving ? const Text('保存中...') : const Text('作成'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}