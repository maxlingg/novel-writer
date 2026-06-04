import 'package:flutter/material.dart';
import '../models/tool_call.dart';

/// 工具调用卡片组件
class ToolCallCard extends StatelessWidget {
  final ToolCall toolCall;

  const ToolCallCard({super.key, required this.toolCall});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 32),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(context).withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getStatusIcon(),
            size: 18,
            color: _getStatusColor(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      toolCall.name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (toolCall.durationMs != null)
                      Text(
                        '${toolCall.durationMs}ms',
                        style: theme.textTheme.labelSmall,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                if (toolCall.arguments.isNotEmpty)
                  Text(
                    '参数: ${_formatArguments(toolCall.arguments)}',
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (toolCall.error != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '错误: ${toolCall.error}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (toolCall.status) {
      case ToolCallStatus.pending:
        return Icons.schedule;
      case ToolCallStatus.running:
        return Icons.sync;
      case ToolCallStatus.completed:
        return Icons.check_circle;
      case ToolCallStatus.failed:
        return Icons.error;
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (toolCall.status) {
      case ToolCallStatus.pending:
        return Colors.grey;
      case ToolCallStatus.running:
        return Colors.blue;
      case ToolCallStatus.completed:
        return Colors.green;
      case ToolCallStatus.failed:
        return Theme.of(context).colorScheme.error;
    }
  }

  String _formatArguments(Map<String, dynamic> args) {
    return args.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
  }
}
