import '../tool_registry.dart';
import '../../utils/file_helper.dart';

/// 文件写入工具
class FileWriteTool {
  static ToolDefinition get definition => ToolDefinition(
        name: 'file_write',
        description: '将内容写入到指定章节文件中。可以创建新文件或覆盖已有文件。',
        parameters: {
          'project_id': ToolParameter(
            type: 'string',
            description: '项目ID',
            isRequired: true,
          ),
          'chapter_id': ToolParameter(
            type: 'string',
            description: '章节ID（可选，如果不提供则创建新章节）',
          ),
          'chapter_title': ToolParameter(
            type: 'string',
            description: '章节标题（创建新章节时使用）',
          ),
          'content': ToolParameter(
            type: 'string',
            description: '要写入的内容',
            isRequired: true,
          ),
          'append': ToolParameter(
            type: 'boolean',
            description: '是否追加到文件末尾（默认false，即覆盖）',
          ),
        },
        execute: _execute,
      );

  static Future<String> _execute(Map<String, dynamic> args) async {
    final projectId = args['project_id'] as String? ?? '';
    final chapterId = args['chapter_id'] as String?;
    final chapterTitle = args['chapter_title'] as String? ?? '未命名章节';
    final content = args['content'] as String? ?? '';
    final append = args['append'] as bool? ?? false;

    if (projectId.isEmpty) {
      return '错误：缺少 project_id 参数';
    }

    try {
      final id = chapterId ?? FileHelper.generateId();
      final filePath = await FileHelper.getChapterFilePath(projectId, id);

      if (append && await FileHelper.fileExists(filePath)) {
        final existing = await FileHelper.readTextFile(filePath);
        await FileHelper.writeTextFile(filePath, '$existing\n$content');
      } else {
        await FileHelper.writeJsonFile(filePath, {
          'id': id,
          'projectId': projectId,
          'title': chapterTitle,
          'content': content,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      return '文件写入成功: $chapterTitle ($id)';
    } catch (e) {
      return '文件写入失败: $e';
    }
  }
}
