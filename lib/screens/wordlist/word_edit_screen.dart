import 'package:flutter/material.dart';
import 'package:original_dict_app/repository/card_repository.dart';
import 'package:original_dict_app/repository/tag_repository.dart';
import 'package:original_dict_app/repository/card_tags_repository.dart';
import 'package:original_dict_app/models/card_entity.dart';
import 'package:original_dict_app/models/tag_entity.dart';
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

  List<TagEntity> _allTags = [];
  List<TagEntity> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final tags = await TagRepository.instance.getTags();
    setState(() => _allTags = tags);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _introController.dispose();
    super.dispose();
  }

  Future<void> _openTagSelector() async {
    if (_allTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タグがまだ登録されていません')),
      );
      return;
    }

    final selected = await showDialog<List<TagEntity>>(
      context: context,
      builder: (context) {
        final tempSelected = List<TagEntity>.from(_selectedTags);
        return AlertDialog(
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
                    if (checked == true) {
                      tempSelected.add(tag);
                    } else {
                      tempSelected.removeWhere((t) => t.id == tag.id);
                    }
                    // setStateではなくDialogのStatefulBuilderが望ましいが簡略化
                    (context as Element).markNeedsBuild();
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
        );
      },
    );

    if (selected != null) {
      setState(() => _selectedTags = selected);
    }
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      // 入力値をサニタイズ
      final name = sanitizeSimple(_nameController.text.trim());
      final intro = sanitizeSimple(_introController.text.trim());

      final newCard = CardEntity(
        id: null, // DBが採番
        name: name,
        nameHira: '',
        intro: intro,
        introHira: '',
        isFave: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // まずカードをDBに登録
      final cardId = await CardRepository.instance.insertCard(newCard);

      // 選択されたタグをcard_tagsテーブルに登録
      for (final tag in _selectedTags) {
        if (tag.id != null) {
          await CardTagRepository.instance.attachTag(cardId, tag.id!);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('カードを保存しました')),
        );
        Navigator.pop(context, true);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.local_offer_outlined),
            tooltip: 'タグを選択',
            onPressed: _openTagSelector,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                maxLines: 9,
              ),
              const SizedBox(height: 12),
              if (_selectedTags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: _selectedTags
                      .map((t) => Chip(label: Text(t.name)))
                      .toList(),
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
