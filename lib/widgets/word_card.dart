import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:original_dict_app/controller/word_selection_scope.dart';
import 'package:original_dict_app/widgets/favorite_mark.dart';
import 'package:original_dict_app/widgets/selection_check.dart';

class WordCard extends StatefulWidget {
  final int id;             // ★ 追加：一意ID
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

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  static const _dateStyle = TextStyle(fontSize: 12, color: Colors.grey);

  void _openDetail() {
    // 通常タップ時（選択モードでないとき）
    debugPrint('open detail: ${widget.name}');
  }

  @override
  Widget build(BuildContext context) {
    final controller = WordSelectionScope.of<int>(context);
    final inSelect = controller.selectionMode;
    final isSelected = controller.selectedIds.contains(widget.id);

    // 選択中の見た目
    final cardColor = isSelected
      ? Theme.of(context).colorScheme.primaryContainer
      : Theme.of(context).colorScheme.surface;

    return SizedBox(
      width: 160,
      height: 115,
      child: GestureDetector(
        // 長押し → 選択モードに入りつつ自分を選択
        onLongPressStart: (_) {
          HapticFeedback.selectionClick(); //スマホで軽いバイブレーションを1回鳴らす
          if (!controller.selectionMode) {
            controller.enterAndSelect(widget.id);
          } else {
            controller.toggle(widget.id);
          }
        },
        child: InkWell( //タップに反応して「波紋」を出す押せる要素ウィジェット
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (inSelect) {
              // 選択モード中はタップ＝トグル
              controller.toggle(widget.id);
            } else {
              // 通常時は詳細へ
              _openDetail();
            }
          },
          child: Card(
            elevation: 1,
            clipBehavior: Clip.antiAlias, //はみ出した描画をどう扱うか設定: 切り取り + 境界を滑らかにする
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: cardColor,
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
                            widget.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          widget.limitedIntro,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(widget.updatedAt, style: _dateStyle),
                      ),
                    ],
                  ),
                ),
                // チェックマーク（選択モードで表示）
                if (inSelect) 
                  Positioned(
                    top: 8,
                    right: 8,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 120),
                      scale: 1.0,
                      child: SelectionCheck(isSelected: isSelected),
                    ),
                  ),
                if (!inSelect)
                  // お気に入りボタン
                  Positioned(
                    top: 12,
                    right: 8,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 120),
                      scale: 1.0,
                      child: FavoriteMark(isFave: widget.isFave, backgroundColor: cardColor),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}