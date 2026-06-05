import 'package:flutter/foundation.dart';
import 'tools/file_write_tool.dart';
import 'tools/file_read_tool.dart';
import 'tools/file_browse_tool.dart';
import 'tools/file_manage_tool.dart';
import 'tools/create_project_tool.dart';
import 'tools/skill_lookup_tool.dart';
import 'tools/web_search_tool.dart';

/// 工具定义
class ToolDefinition {
  final String name;
  final String description;
  final Map<String, ToolParameter> parameters;
  final Future<String> Function(Map<String, dynamic> args) execute;

  ToolDefinition({
    required this.name,
    required this.description,
    required this.parameters,
    required this.execute,
  });

  /// 转换为JSON Schema格式（用于AI函数调用）
  Map<String, dynamic> toJsonSchema() {
    return {
      'type': 'function',
      'function': {
        'name': name,
        'description': description,
        'parameters': {
          'type': 'object',
          'properties': parameters.map((key, param) => MapEntry(key, param.toJson())),
          'required': parameters.entries
              .where((e) => e.value.isRequired)
              .map((e) => e.key)
              .toList(),
        },
      },
    };
  }
}

/// 工具参数定义
class ToolParameter {
  final String type;
  final String description;
  final bool isRequired;
  final String? defaultValue;
  final List<String>? enumValues;

  ToolParameter({
    required this.type,
    required this.description,
    this.isRequired = false,
    this.defaultValue,
    this.enumValues,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'type': type,
      'description': description,
    };
    if (enumValues != null) {
      map['enum'] = enumValues;
    }
    return map;
  }
}

/// 工具注册表
class ToolRegistry extends ChangeNotifier {
  final Map<String, ToolDefinition> _tools = {};

  Map<String, ToolDefinition> get tools => Map.unmodifiable(_tools);
  List<ToolDefinition> get toolList => _tools.values.toList();

  /// 初始化内置工具
  void initBuiltInTools() {
    registerTool(FileWriteTool.definition);
    registerTool(FileReadTool.definition);
    registerTool(FileBrowseTool.definition);
    registerTool(FileManageTool.definition);
    registerTool(CreateProjectTool.definition);
    registerTool(SkillLookupTool.definition);
    registerTool(WebSearchTool.definition);
  }

  /// 注册工具
  void registerTool(ToolDefinition tool) {
    _tools[tool.name] = tool;
    notifyListeners();
  }

  /// 注销工具
  void unregisterTool(String name) {
    _tools.remove(name);
    notifyListeners();
  }

  /// 执行工具
  Future<String> executeTool({
    required String name,
    required Map<String, dynamic> arguments,
  }) async {
    final tool = _tools[name];
    if (tool == null) {
      throw Exception('工具未找到: $name');
    }

    try {
      return await tool.execute(arguments);
    } catch (e) {
      debugPrint('工具执行失败 [$name]: $e');
      return '工具执行失败: $e';
    }
  }

  /// 获取所有工具的JSON Schema列表
  List<Map<String, dynamic>> getToolSchemas() {
    return toolList.map((t) => t.toJsonSchema()).toList();
  }

  /// 获取工具描述列表（用于系统提示词）
  String getToolDescriptions() {
    final buffer = StringBuffer();
    for (final tool in toolList) {
      buffer.writeln('## ${tool.name}');
      buffer.writeln(tool.description);
      buffer.writeln('参数:');
      for (final entry in tool.parameters.entries) {
        final param = entry.value;
        buffer.writeln('  - ${entry.key} (${param.type}): ${param.description}');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }
}
