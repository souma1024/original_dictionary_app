import 'package:flutter/material.dart';
import 'package:original_dict_app/repository/tag_repository.dart';
import 'package:original_dict_app/models/tag_entity.dart';
import 'package:sqflite/sqflite.dart';

class TagDetailScreen extends StatefulWidget {
  final int tagId;
  const TagDetailScreen({super.key, required this.tagId});

  @override
  State<TagDetailScreen> createState() => _TagDetailScreenState();
}

class _TagDetailScreenState extends State<TagDetailScreen> {
  final _repo = TagRepository.instance;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  TagEntity? _tag;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final t = await _repo.getTagById(widget.tagId);
      _tag = t;
      _nameCtrl.text = t?.name ?? '';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _tag == null) return;
    setState(() => _saving = true);
    try {
      final updated = TagEntity(
        id: _tag!.id,
        name: _nameCtrl.text.trim(),
        createdAt: _tag!.createdAt, // 変更せず
        updatedAt: DateTime.now(),  // UI側でも更新（repo側でも上書きされる想定）
      );
      await _repo.updateTag(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('更新しました')));
      Navigator.of(context).pop(true);
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('更新に失敗しました: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('タグを削除しますか？'),
        content: Text('「${_tag?.name ?? ''}」を削除します。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('キャンセル')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('削除')),
        ],
      ),
    );
    if (ok == true) {
      await _repo.deleteTag(widget.tagId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('削除しました')));
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('タグ詳細'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _saving || _loading ? null : _delete,
            tooltip: '削除',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                      label: _saving ? const Text('保存中...') : const Text('保存'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
