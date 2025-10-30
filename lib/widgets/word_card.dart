import 'package:flutter/material.dart';
import 'package:original_dict_app/widgets/favorite_mark.dart';
import 'package:original_dict_app/controller/word_selection_scope.dart';
import 'package:flutter/services.dart';
import 'package:original_dict_app/widgets/selection_check.dart';

class WordCard extends StatelessWidget {
  final int id;
  final String name;
  final String limitedIntro;
  final bool isFave;
  final String updatedAt;

  const WordCard({
    super.key,
    required this.id,
    required this.name,
    required this.limitedIntro,
    required this.isFave,
    required this.updatedAt,
  });

  void _openDetail() {
    debugPrint('open detail: $name');
  }

  @override
  Widget build(BuildContext context) {
    final sel = WordSelectionScope.of<int>(context);
    final theme = Theme.of(context);

     // 静的コンテンツ（再利用される）
    final staticBody = Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              limitedIntro,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              updatedAt,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );

    return SizedBox(
      width: 160,
      height: 115,
      child: Card(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onLongPress: () {
            HapticFeedback.selectionClick();
            if (!sel.selectionMode) {
              sel.enterAndSelect(id);
            } else {
              sel.toggle(id);
            }
          },
          onTap: () {
            if (sel.selectionMode) {
              sel.toggle(id);
            } else {
              _openDetail();
            }
          },
          child: Stack(
            children: [
              // 背景色だけ isSelected を購読（軽い AnimatedContainer）
              ValueListenableBuilder<bool>(
                valueListenable: sel.isSelectedListenable(id),
                builder: (context, isSelected, child) {
                  final cardColor = isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surface;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOut,
                    color: cardColor,
                    child: child, // ← 下の staticBody がそのまま使い回される
                  );
                },
                child: staticBody,
              ),

              // チェック（選択モードのときだけ表示）
              Positioned(
                top: 8,
                right: 8,
                child: ValueListenableBuilder<bool>(
                  valueListenable: sel.selectionModeListenable,
                  builder: (context, inSelect, _) {
                    if (!inSelect) return const SizedBox.shrink();
                    // isSelected は「チェックの中」だけで購読
                    return ValueListenableBuilder<bool>(
                      valueListenable: sel.isSelectedListenable(id),
                      builder: (context, isSelected, __) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          child: SelectionCheck(
                            key: ValueKey<bool>(isSelected),
                            isSelected: isSelected,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // お気に入り（通常モードのみ）
              Positioned(
                top: 12,
                right: 8,
                child: ValueListenableBuilder<bool>(
                  valueListenable: sel.selectionModeListenable,
                  builder: (context, inSelect, _) {
                    if (inSelect) return const SizedBox.shrink();
                    // ここは静的。背景色は上の AnimatedContainer に合わせたいなら
                    // FavoriteMark 側で透明背景にするか、薄めの色で OK
                    return FavoriteMark(isFave: isFave, backgroundColor: Colors.transparent);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}