import 'package:flutter/material.dart';
import 'package:original_dict_app/controller/word_selection_controller.dart';

// 選択モードの上部ウィジェット
class SelectionToolbar extends StatelessWidget {
  const SelectionToolbar({
    super.key,
    required this.selection,
    required this.onDeletePressed,
    required this.onExitPressed,
  });

  final WordSelectionController<int> selection;
  final VoidCallback onDeletePressed; //VoidCallbackは引数と戻り値がvoidの関数
  final VoidCallback onExitPressed;

  @override
  Widget build(BuildContext context) {
    return  ValueListenableBuilder<Set<int>>(
      valueListenable: selection.selectedIdsListenable,
      builder: (context, set, _) {
        final count = set.length;
        return Row(
        children: [
          Text('$count 件選択中', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          IconButton(
            tooltip: '選択解除',
            icon: const Icon(Icons.close),
            onPressed: onExitPressed,
          ),
          IconButton(
            tooltip: 'カードを削除',
            icon: const Icon(Icons.delete),
            onPressed: onDeletePressed,
          ),
        ],
      );
      }
    );
  }
}