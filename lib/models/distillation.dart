import 'package:uuid/uuid.dart';

/// 蒸馏状态
enum DistillationStatus {
  idle,       // 空闲
  pending,    // 待处理
  processing, // 处理中
  completed,  // 已完成
  failed,     // 失败
}

/// 蒸馏类型
enum DistillationType {
  summary,    // 摘要
  outline,    // 大纲
  character,  // 人物提炼
  theme,      // 主题提炼
  structure,  // 结构分析
  custom,     // 自定义
}

/// 蒸馏模型
class Distillation {
  final String id;
  String name;
  String description;
  DistillationType type;
  String? projectId;         // 关联的项目ID
  List<String>? chapterIds;   // 要蒸馏的章节ID列表
  String? prompt;            // 自定义提示词
  String content;            // 蒸馏结果
  DistillationStatus status;
  double? progress;          // 进度 0-1
  String? error;             // 错误信息
  Map<String, dynamic>? config; // 配置参数
  DateTime createdAt;
  DateTime? startedAt;
  DateTime? completedAt;
  Map<String, dynamic> metadata;

  Distillation({
    String? id,
    required this.name,
    this.description = '',
    required this.type,
    this.projectId,
    this.chapterIds,
    this.prompt,
    this.content = '',
    this.status = DistillationStatus.idle,
    this.progress,
    this.error,
    this.config,
    DateTime? createdAt,
    this.startedAt,
    this.completedAt,
    this.metadata = const {},
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory Distillation.fromJson(Map<String, dynamic> json) {
    return Distillation(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      projectId: json['projectId'] as String?,
      chapterIds: (json['chapterIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      prompt: json['prompt'] as String?,
      content: json['content'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
      progress: (json['progress'] as num?)?.toDouble(),
      error: json['error'] as String?,
      config: json['config'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'projectId': projectId,
      'chapterIds': chapterIds,
      'prompt': prompt,
      'content': content,
      'status': status.name,
      'progress': progress,
      'error': error,
      'config': config,
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  static DistillationType _parseType(String? type) {
    switch (type) {
      case 'summary':
        return DistillationType.summary;
      case 'outline':
        return DistillationType.outline;
      case 'character':
        return DistillationType.character;
      case 'theme':
        return DistillationType.theme;
      case 'structure':
        return DistillationType.structure;
      case 'custom':
        return DistillationType.custom;
      default:
        return DistillationType.summary;
    }
  }

  static DistillationStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return DistillationStatus.pending;
      case 'processing':
        return DistillationStatus.processing;
      case 'completed':
        return DistillationStatus.completed;
      case 'failed':
        return DistillationStatus.failed;
      default:
        return DistillationStatus.idle;
    }
  }

  Distillation copyWith({
    String? name,
    String? description,
    DistillationType? type,
    String? projectId,
    List<String>? chapterIds,
    String? prompt,
    String? content,
    DistillationStatus? status,
    double? progress,
    String? error,
    Map<String, dynamic>? config,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Distillation(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      projectId: projectId ?? this.projectId,
      chapterIds: chapterIds ?? this.chapterIds,
      prompt: prompt ?? this.prompt,
      content: content ?? this.content,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      config: config ?? this.config,
      createdAt: createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// 蒸馏模板模型
class DistillationTemplate {
  final String id;
  String name;
  String description;
  DistillationType type;
  String promptTemplate;   // 提示词模板
  Map<String, dynamic> defaultConfig;
  bool isBuiltIn;
  DateTime createdAt;

  DistillationTemplate({
    String? id,
    required this.name,
    this.description = '',
    required this.type,
    required this.promptTemplate,
    this.defaultConfig = const {},
    this.isBuiltIn = false,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
}

/// 蒸馏历史记录
class DistillationHistory {
  final String id;
  String distillationId;
  String action;          // 动作：create, update, export等
  String? detail;
  DateTime createdAt;

  DistillationHistory({
    String? id,
    required this.distillationId,
    required this.action,
    this.detail,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
}
