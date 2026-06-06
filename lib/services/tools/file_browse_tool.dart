import 'dart:io';
import '../tool_registry.dart';
import '../../utils/file_helper.dart';

/// 文件浏览工具
class FileBrowseTool {
  static ToolDefinition get definition => ToolDefinition(
        name: 'file_browse',
        description: '浏览项目中的章节文件列表，获取项目结构概览。',
        parameters: {
          'project_id': ToolParameter(
            type: 'string',
            description: '项目ID',
            isRequired: true,
          ),
          'include_content': ToolParameter(
            type: 'boolean',
            description: '是否包含每个章节的内容摘要（默认false）',
          ),
        },
        execute: _execute,
      );

  static Future<String> _execute(Map<String, dynamic> args) async {
    final projectId = args['project_id'] as String? ?? '';
    final includeContent = args['include_content'] as bool? ?? false;

    if (projectId.isEmpty) {
      return '错误：缺少 project_id 参数';
    }

    try {
      final projectDir = await FileHelper.getProjectDirectory(projectId);
      final chaptersDir = '${projectDir.path}/chapters';

      if (!await FileHelper.directoryExists(chaptersDir)) {
        return '该项目暂无章节';
      }

      final files = await FileHelper.listDirectory(chaptersDir);
      final buffer = StringBuffer('项目章节列表：\n');

      for (final entity in files) {
        if (entity is! File || !entity.path.endsWith('.json')) continue;

        try {
          final json = await FileHelper.readJsonFile(entity.path);
          if (json == null) continue;

          final title = json['title'] as String? ?? '未命名';
          final wordCount = json['wordCount'] as int? ?? 0;
          final status = json['status'] as String? ?? 'draft';

          buffer.writeln('  - $title (字数: $wordCount, 状态: $status)');

          if (includeContent) {
            final content = json['content'] as String? ?? '';
            final preview = content.length > 200
                ? '${content.substring(0, 200)}...'
                : content;
            buffer.writeln('    摘要: $preview');
          }
        } catch (_) {
          continue;
        }
      }

      return buffer.toString();
    } catch (e) {
      return '浏览失败: $e';
    }
  }
}
