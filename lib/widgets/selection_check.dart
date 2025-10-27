import 'package:flutter/material.dart';

// カード選択のチェックボタンを定義
class SelectionCheck extends StatelessWidget {
  final bool isSelected;
  const SelectionCheck({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final sel = isSelected;
    return CircleAvatar(
      radius: 12,
      backgroundColor: sel ? Theme.of(context).colorScheme.primary : Colors.white,
      child: Icon(
        sel ? Icons.check : Icons.circle_outlined,
        size: 16,
        color: sel ? Colors.white : Colors.grey,
      ),
    );
  }
}