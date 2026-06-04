import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../utils/constants.dart';

/// 章节列表项组件
class ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final int? index;

  const ChapterTile({
    super.key,
    required this.chapter,
    required this.onTap,
    this.onLongPress,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          '${chapter.sortOrder + 1}',
          style: const TextStyle(fontSize: 12),
        ),
      ),
      title: Text(
        chapter.title,
        style: theme.textTheme.bodyLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Text(
            '${chapter.wordCount} 字',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(width: 8),
          _StatusIndicator(status: chapter.status),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

/// 章节状态指示器
class _StatusIndicator extends StatelessWidget {
  final ChapterStatus status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      ChapterStatus.draft => (Colors.grey, '草稿'),
      ChapterStatus.writing => (Colors.blue, '写作中'),
      ChapterStatus.completed => (Colors.green, '已完成'),
      ChapterStatus.revised => (Colors.orange, '已修订'),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 11),
        ),
      ],
    );
  }
}
