import 'package:flutter/material.dart';
import 'package:original_dict_app/repository/card_repository.dart';
import 'package:original_dict_app/repository/tag_repository.dart';
import 'package:original_dict_app/repository/card_tags_repository.dart';
import 'package:original_dict_app/models/card_entity.dart';
import 'package:original_dict_app/models/tag_entity.dart';
import 'package:original_dict_app/utils/security/input_sanitizer.dart';

class WordDetailScreen extends StatefulWidget {
  final int cardId;

  const WordDetailScreen({super.key, required this.cardId});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  CardEntity? _card;
  bool _loading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _introController = TextEditingController();

  List<TagEntity> _allTags = [];
  List<TagEntity> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _introController.dispose();
    super.dispose();
  }

  Future<void> _loadCard() async {
    final card = await CardRepository.instance.getCardById(widget.cardId);
    final tagIds = await CardTagRepository.instance.getTagIdsByCard(widget.cardId);
    final allTags = await TagRepository.instance.getTags();
    final selected = allTags.where((t) => tagIds.contains(t.id)).toList();

    setState(() {
      _card = card;
      _allTags = allTags;
      _selectedTags = selected;
      _nameController.text = card?.name ?? '';
      _introController.text = card?.intro ?? '';
      _loading = false;
    });
  }

  Future<void> _openTagSelector() async {
    final selected = await showDialog<List<TagEntity>>(
      context: context,
      builder: (context) {
        final tempSelected = List<TagEntity>.from(_selectedTags);
        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            title: const Text('タグを選択'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _allTags.map((tag) {
                  final isSelected = tempSelected.any((t) => t.id == tag.id);
                  return CheckboxListTile(
                    title: Text(tag.name),
                    value: isSelected,
                    onChanged: (checked) {
                      setStateDialog(() {
                        if (checked == true) {
                          tempSelected.add(tag);
                        } else {
                          tempSelected.removeWhere((t) => t.id == tag.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, _selectedTags),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, tempSelected),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => _selectedTags = selected);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() || _card == null) return;

    setState(() => _isSaving = true);

    try {
      final updated = _card!.copyWith(
        name: sanitizeSimple(_nameController.text.trim()),
        intro: sanitizeSimple(_introController.text.trim()),
        updatedAt: DateTime.now(),
      );

      await CardRepository.instance.updateCard(updated);

      // タグ更新
      final existing = await CardTagRepository.instance.getTagIdsByCard(_card!.id!);
      for (final tid in existing) {
        await CardTagRepository.instance.detachTag(_card!.id!, tid);
      }
      for (final tag in _selectedTags) {
        if (tag.id != null) {
          await CardTagRepository.instance.attachTag(_card!.id!, tag.id!);
        }
      }

      setState(() {
        _card = updated;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('変更を保存しました')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存中にエラーが発生しました: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_card?.name ?? '読み込み中...'),
        actions: [
          // 編集中のみタグ選択ボタンを表示
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.local_offer_outlined),
              tooltip: 'タグを選択',
              onPressed: _openTagSelector,
            ),

          // 編集モード切り替え or 保存ボタン
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            tooltip: _isEditing ? '保存' : '編集',
            onPressed: _isEditing
                ? _isSaving
                ? null
                : _saveChanges
                : () => setState(() => _isEditing = true),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _card == null
          ? const Center(child: Text('データが見つかりませんでした'))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 単語名
                _isEditing
                    ? TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '単語',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                  v == null || v.isEmpty ? '単語を入力してください' : null,
                )
                    : Text(
                  _card!.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // 説明・意味
                _isEditing
                    ? TextFormField(
                  controller: _introController,
                  minLines: 3,
                  maxLines: 9,
                  decoration: const InputDecoration(
                    labelText: '説明・意味',
                    border: OutlineInputBorder(),
                  ),
                )
                    : Text(
                  _card!.intro,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),

                // タグ一覧
                if (_selectedTags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: _selectedTags
                        .map((t) => Chip(
                      label: Text(t.name),
                      onDeleted: _isEditing
                          ? () => setState(
                              () => _selectedTags.remove(t))
                          : null,
                    ))
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
