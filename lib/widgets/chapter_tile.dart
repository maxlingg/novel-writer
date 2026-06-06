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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${date.month}/${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Center(
            child: Text(
              '${chapter.sortOrder + 1}',
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        title: Text(
          chapter.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              '${chapter.wordCount} 字',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(width: 4),
            Text(
              '·',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _formatDate(chapter.updatedAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(width: 8),
            _StatusIndicator(status: chapter.status),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: theme.colorScheme.outline),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
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
