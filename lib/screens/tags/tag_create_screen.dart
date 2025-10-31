import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:original_dict_app/repository/tag_repository.dart';
import 'package:original_dict_app/models/tag_entity.dart';


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

  Timer? _debounce;
  List<TagEntity> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameCtrl.removeListener(_onNameChanged);
    _nameCtrl.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final q = _nameCtrl.text.trim();
      if (!mounted) return;
      if (q.isEmpty) {
        setState(() => _suggestions = []);
        return;
      }
      final list = await _repo.searchSimilarTags(q);
      if (!mounted) return;

      // 完全一致は候補から除外（必要なら）
      final filtered = list.where((t) => t.name != q).toList();
      setState(() => _suggestions = filtered);
    });
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

              // 追加: サジェスト領域
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: _suggestions.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 220),
                          child: Material(
                            elevation: 1,
                            borderRadius: BorderRadius.circular(8),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: _suggestions.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, i) {
                                final t = _suggestions[i];
                                return ListTile(
                                  dense: true,
                                  title: Text(t.name),
                                  onTap: () {
                                    _nameCtrl.text = t.name;
                                    _nameCtrl.selection = TextSelection.fromPosition(
                                      TextPosition(offset: t.name.length),
                                    );
                                    setState(() => _suggestions = []);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
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