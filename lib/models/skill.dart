import 'package:uuid/uuid.dart';

/// 技能模型
class Skill {
  final String id;
  String name;
  String description;
  String category;         // 分类：写作、编辑、分析等
  String icon;
  String systemPrompt;      // 技能对应的系统提示词
  List<String> requiredTools; // 技能需要的工具列表
  Map<String, dynamic> parameters; // 技能参数
  bool isBuiltIn;          // 是否为内置技能
  bool isEnabled;
  int usageCount;
  DateTime createdAt;
  DateTime updatedAt;

  Skill({
    String? id,
    required this.name,
    this.description = '',
    this.category = '',
    this.icon = '',
    this.systemPrompt = '',
    this.requiredTools = const [],
    this.parameters = const {},
    this.isBuiltIn = false,
    this.isEnabled = true,
    this.usageCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      systemPrompt: json['systemPrompt'] as String? ?? '',
      requiredTools: (json['requiredTools'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      parameters: json['parameters'] as Map<String, dynamic>? ?? {},
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      isEnabled: json['isEnabled'] as bool? ?? true,
      usageCount: json['usageCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'icon': icon,
      'systemPrompt': systemPrompt,
      'requiredTools': requiredTools,
      'parameters': parameters,
      'isBuiltIn': isBuiltIn,
      'isEnabled': isEnabled,
      'usageCount': usageCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Skill copyWith({
    String? name,
    String? description,
    String? category,
    String? icon,
    String? systemPrompt,
    List<String>? requiredTools,
    Map<String, dynamic>? parameters,
    bool? isEnabled,
  }) {
    return Skill(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      requiredTools: requiredTools ?? this.requiredTools,
      parameters: parameters ?? this.parameters,
      isBuiltIn: isBuiltIn,
      isEnabled: isEnabled ?? this.isEnabled,
      usageCount: usageCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
