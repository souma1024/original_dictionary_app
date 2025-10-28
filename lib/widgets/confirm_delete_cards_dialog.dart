import 'package:flutter/material.dart';

Future<bool> confirmDeleteCardsDialog(BuildContext context, int count) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('選択した単語を削除しますか？'),
      content: Text('合計 $count 件を削除します。取り消せません。'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('削除')),
      ],
    ),
  );
  return ok == true;
}