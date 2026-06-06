import 'package:uuid/uuid.dart';

/// 聊天会话模型
class ChatSession {
  final String id;
  String projectId;
  String title;
  String systemPrompt;
  String modelConfigId;    // 关联的AI模型配置ID
  DateTime createdAt;
  DateTime updatedAt;

  ChatSession({
    String? id,
    required this.projectId,
    this.title = '新对话',
    this.systemPrompt = '',
    this.modelConfigId = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String?,
      projectId: json['projectId'] as String? ?? '',
      title: json['title'] as String? ?? '新对话',
      systemPrompt: json['systemPrompt'] as String? ?? '',
      modelConfigId: json['modelConfigId'] as String? ?? '',
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
      'projectId': projectId,
      'title': title,
      'systemPrompt': systemPrompt,
      'modelConfigId': modelConfigId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ChatSession copyWith({
    String? projectId,
    String? title,
    String? systemPrompt,
    String? modelConfigId,
  }) {
    return ChatSession(
      id: id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      modelConfigId: modelConfigId ?? this.modelConfigId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
