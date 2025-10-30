import 'package:flutter/material.dart';
import 'package:original_dict_app/models/tag_entity.dart';
import 'package:original_dict_app/repository/tag_repository.dart';
import 'package:original_dict_app/screens/tags/tag_detail_screen.dart';
import 'package:original_dict_app/screens/tags/tag_create_screen.dart';
import 'package:original_dict_app/utils/db/time_helper.dart';
import 'package:original_dict_app/screens/common_scaffold.dart';

class TagListScreen extends StatefulWidget {
  const TagListScreen({super.key});

  @override
  State<TagListScreen> createState() => _TagListScreenState();
}

class _TagListScreenState extends State<TagListScreen> {
  final _repo = TagRepository.instance;
  late Future<List<TagEntity>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<TagEntity>> _load() async {
    final list = await _repo.getTags();
    // updatedAt DESC, id DESC で整列（DB側でORDER BYしていない前提なのでここで）
    list.sort((a, b) {
      final t = b.updatedAt.compareTo(a.updatedAt);
      if (t != 0) return t;
      return (b.id ?? 0).compareTo(a.id ?? 0);
    });
    return list;
  }

  Future<void> _reload() async {
    final f = _load();            // 先にFutureを作る
    setState(() {                 // setStateは同期処理だけ
      _future = f;
    });
    await f;    
  }

  Future<void> _onTap(TagEntity tag) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TagDetailScreen(tagId: tag.id!)),
    );
    if (changed == true) _reload();
  }

  Future<void> _onLongPress(TagEntity tag) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('タグを削除しますか？'),
        content: Text('「${tag.name}」を削除します。単語カードにつけられたこのタグは自動的に解除されます。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('キャンセル')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('削除')),
        ],
      ),
    );
    if (ok == true) {
      await _repo.deleteTag(tag.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('削除しました: ${tag.name}')),
      );
      _reload();
    }
  }

  void _onCreatePressed() async {
    final created = await Navigator.of(context).push<TagEntity>(
      MaterialPageRoute(builder: (_) => const TagCreateScreen()),
    );
    if (created != null) {
      setState(() {
        _future = _future.then((list) {
          final next = [...list, created];
          next.sort((a, b) {
            final t = b.updatedAt.compareTo(a.updatedAt);
            if (t != 0) return t;
            return (b.id ?? 0).compareTo(a.id ?? 0);
          });
          return next;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'タグ管理',
      body: FutureBuilder<List<TagEntity>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('読み込みに失敗しました${snap.error}'));
          }
          final tags = snap.data ?? const [];
          if (tags.isEmpty) {
            return const Center(child: Text('タグがありません。右下の＋から追加できます。'));
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              itemCount: tags.length,
              itemExtent: 64,
              itemBuilder: (context, i) {
                final t = tags[i];
                return ListTile(
                  title: Text(t.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('更新: ${TimeHelper.formatDateTime(t.updatedAt)}', style: const TextStyle(fontSize: 12)),
                  onTap: () => _onTap(t),
                  onLongPress: () => _onLongPress(t),
                );
              },
            ),
          );
        },
      ),
      fab: FloatingActionButton(
        onPressed: _onCreatePressed,
        child: const Icon(Icons.add),
      ),
    );
  }
}