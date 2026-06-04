import '../tool_registry.dart';
import '../../utils/file_helper.dart';

/// 文件管理工具
class FileManageTool {
  static ToolDefinition get definition => ToolDefinition(
        name: 'file_manage',
        description: '管理章节文件，包括重命名、删除、移动排序等操作。',
        parameters: {
          'action': ToolParameter(
            type: 'string',
            description: '操作类型：rename, delete, reorder',
            isRequired: true,
            enumValues: ['rename', 'delete', 'reorder'],
          ),
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
          'new_title': ToolParameter(
            type: 'string',
            description: '新标题（rename操作时使用）',
          ),
          'new_sort_order': ToolParameter(
            type: 'integer',
            description: '新的排序位置（reorder操作时使用）',
          ),
        },
        execute: _execute,
      );

  static Future<String> _execute(Map<String, dynamic> args) async {
    final action = args['action'] as String? ?? '';
    final projectId = args['project_id'] as String? ?? '';
    final chapterId = args['chapter_id'] as String? ?? '';

    if (projectId.isEmpty || chapterId.isEmpty) {
      return '错误：缺少必要参数';
    }

    try {
      final filePath = await FileHelper.getChapterFilePath(projectId, chapterId);
      final json = await FileHelper.readJsonFile(filePath);

      if (json == null) {
        return '错误：章节不存在';
      }

      switch (action) {
        case 'rename':
          final newTitle = args['new_title'] as String? ?? '';
          if (newTitle.isEmpty) return '错误：缺少新标题';
          json['title'] = newTitle;
          json['updatedAt'] = DateTime.now().toIso8601String();
          await FileHelper.writeJsonFile(filePath, json);
          return '重命名成功: $newTitle';

        case 'delete':
          await FileHelper.deleteFile(filePath);
          return '删除成功';

        case 'reorder':
          final newOrder = args['new_sort_order'] as int?;
          if (newOrder == null) return '错误：缺少新的排序位置';
          json['sortOrder'] = newOrder;
          json['updatedAt'] = DateTime.now().toIso8601String();
          await FileHelper.writeJsonFile(filePath, json);
          return '排序更新成功';

        default:
          return '错误：未知操作类型 $action';
      }
    } catch (e) {
      return '操作失败: $e';
    }
  }
}
