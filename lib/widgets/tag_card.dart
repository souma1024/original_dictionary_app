import 'package:flutter/material.dart';
import 'package:original_dict_app/utils/db/time_helper.dart';
import 'package:original_dict_app/widgets/small_dot.dart';
import 'package:original_dict_app/models/tag_entity.dart';

class TagCard extends StatelessWidget {
  final TagEntity tags;
  final Future<void> Function(TagEntity) onTap;
  final Future<void> Function(TagEntity) onLongPress;
  final Color color;
  final Color dotColor;

  const TagCard({
    super.key,
    required this.tags,
    required this.onTap,
    required this.onLongPress,
    this.color = const Color.fromARGB(255, 231, 242, 249), // 薄い水色
    required this.dotColor
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color, // 薄い水色
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias, // InkWellのリップルを角丸に合わせる
      child: InkWell(
        onTap: () async => await onTap(tags),
        onLongPress: () async => await onLongPress(tags),
        child: ListTile(
          leading: SmallDot(color: dotColor, size: 10, rightMargin: 12),
          title: Text(
            tags.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '更新: ${TimeHelper.formatDateTime(tags.updatedAt)}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
      ),
    );
  }
}