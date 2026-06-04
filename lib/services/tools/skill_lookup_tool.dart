import '../tool_registry.dart';

/// 技能查找工具
class SkillLookupTool {
  static ToolDefinition get definition => ToolDefinition(
        name: 'skill_lookup',
        description: '查找可用的AI技能，获取技能的描述和系统提示词。',
        parameters: {
          'query': ToolParameter(
            type: 'string',
            description: '搜索关键词',
            isRequired: true,
          ),
          'category': ToolParameter(
            type: 'string',
            description: '技能分类（可选）',
          ),
        },
        execute: _execute,
      );

  static Future<String> _execute(Map<String, dynamic> args) async {
    final query = args['query'] as String? ?? '';
    final category = args['category'] as String?;

    if (query.isEmpty) {
      return '错误：搜索关键词不能为空';
    }

    // TODO: 通过 SkillManager 查找技能
    String result = '搜索技能 "$query"';
    if (category != null) {
      result += ' (分类: $category)';
    }
    result += '\n\n找到以下相关技能：\n  - 续写助手\n  - 角色对话生成\n  - 情节分析';
    return result;
  }
}
