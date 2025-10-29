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

    return SizedBox(
      width: 160,
      height: 115,
      child: ValueListenableBuilder<bool>(
        valueListenable: sel.selectionModeListenable,
        builder: (context, inSelect, _) {
          return ValueListenableBuilder<bool>(
            valueListenable: sel.isSelectedListenable(id),
            builder: (context, isSelected, __) {
              final theme = Theme.of(context);
              final cardColor = isSelected
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surface;

              return Card(
                elevation: 1,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: cardColor,
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
                      // 本文
                      Padding(
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
                                updatedAt, style: const TextStyle(fontSize: 12, color: Colors.grey)
                              ),
                            ),
                          ],
                        ),
                      ),
                      // チェック
                      Positioned(
                        top: 8,
                        right: 8,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 150),
                          child: inSelect
                              ? SizedBox(
                                  key: ValueKey('check'),
                                  child: SelectionCheck(isSelected: isSelected),
                                )
                              : const SizedBox.shrink(key: ValueKey('no-check')),
                        ),
                      ),
                      // お気に入り（通常時のみ）
                      if (!inSelect)
                        Positioned(
                          top: 12,
                          right: 8,
                          child: FavoriteMark(isFave: isFave, backgroundColor: cardColor),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}