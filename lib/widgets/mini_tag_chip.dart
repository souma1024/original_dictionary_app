import 'package:flutter/material.dart';
import 'package:original_dict_app/widgets/small_dot.dart';
import 'package:original_dict_app/models/tag_entity.dart';
import 'package:original_dict_app/utils/color_util.dart';

class MiniTagChip extends StatelessWidget {
  final TagEntity tag;
  final Future<void> Function(TagEntity) onTap;
  final Color backgroundColor;

  const MiniTagChip({
    super.key,
    required this.tag,
    required this.onTap,
    this.backgroundColor = const Color.fromARGB(255, 231, 242, 249), // 薄い水色
  });

  @override
  Widget build(BuildContext context) {
    final dot = ColorUtil.fromAny(tag.color);
    return Card(
      color: backgroundColor,
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async => onTap(tag),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SmallDot(color: dot),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 80), // カード幅に合わせて調整
                child: Text(
                  tag.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}