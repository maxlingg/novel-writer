import '../tool_registry.dart';

/// 创建项目工具
class CreateProjectTool {
  static ToolDefinition get definition => ToolDefinition(
        name: 'create_project',
        description: '创建一个新的小说写作项目。',
        parameters: {
          'name': ToolParameter(
            type: 'string',
            description: '项目名称',
            isRequired: true,
          ),
          'description': ToolParameter(
            type: 'string',
            description: '项目描述',
          ),
          'genre': ToolParameter(
            type: 'string',
            description: '小说类型（如：玄幻、都市、科幻等）',
          ),
        },
        execute: _execute,
      );

  static Future<String> _execute(Map<String, dynamic> args) async {
    final name = args['name'] as String? ?? '';
    final description = args['description'] as String? ?? '';
    final genre = args['genre'] as String? ?? '';

    if (name.isEmpty) {
      return '错误：项目名称不能为空';
    }

    // TODO: 通过 ProjectService 创建项目
    return '项目创建成功: $name (类型: $genre)';
  }
}
