import '../tool_registry.dart';
import '../../utils/file_helper.dart';

/// 文件读取工具
class FileReadTool {
  static ToolDefinition get definition => ToolDefinition(
        name: 'file_read',
        description: '读取指定章节文件的内容。可以读取整个文件或指定范围的内容。',
        parameters: {
          'project_id': ToolParameter(
            type: 'string',
            description: '项目ID',
            isRequired: true,
          ),
          'chapter_id': ToolParameter(
            type: 'string',
            description: '章节ID',
            isRequired: true,
          ),
          'max_chars': ToolParameter(
            type: 'integer',
            description: '最大返回字符数（默认5000）',
          ),
        },
        execute: _execute,
      );

  static Future<String> _execute(Map<String, dynamic> args) async {
    final projectId = args['project_id'] as String? ?? '';
    final chapterId = args['chapter_id'] as String? ?? '';
    final maxChars = args['max_chars'] as int? ?? 5000;

    if (projectId.isEmpty || chapterId.isEmpty) {
      return '错误：缺少必要参数';
    }

    try {
      final filePath = await FileHelper.getChapterFilePath(projectId, chapterId);
      final json = await FileHelper.readJsonFile(filePath);

      if (json == null) {
        return '错误：文件不存在';
      }

      final title = json['title'] as String? ?? '';
      final content = json['content'] as String? ?? '';

      String result = '【$title】\n\n';
      if (content.length > maxChars) {
        result += content.substring(0, maxChars);
        result += '\n\n... (内容已截断，共 ${content.length} 字符)';
      } else {
        result += content;
      }

      return result;
    } catch (e) {
      return '文件读取失败: $e';
    }
  }
}
