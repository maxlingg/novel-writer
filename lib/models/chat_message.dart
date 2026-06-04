import '../utils/constants.dart';

/// 聊天消息模型
class ChatMessage {
  final String id;
  String sessionId;
  MessageRole role;
  String content;
  List<ToolCall>? toolCalls;
  String? toolCallId;      // 如果是工具调用结果
  String? toolName;        // 工具名称
  bool isError;
  DateTime createdAt;

  ChatMessage({
    String? id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.toolCalls,
    this.toolCallId,
    this.toolName,
    this.isError = false,
    DateTime? createdAt,
  })  : id = id ?? '',
        createdAt = createdAt ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String?,
      sessionId: json['sessionId'] as String? ?? '',
      role: _parseRole(json['role'] as String?),
      content: json['content'] as String? ?? '',
      toolCalls: (json['toolCalls'] as List<dynamic>?)
          ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
          .toList(),
      toolCallId: json['toolCallId'] as String?,
      toolName: json['toolName'] as String?,
      isError: json['isError'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'role': role.name,
      'content': content,
      'toolCalls': toolCalls?.map((e) => e.toJson()).toList(),
      'toolCallId': toolCallId,
      'toolName': toolName,
      'isError': isError,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 是否为用户消息
  bool get isUser => role == MessageRole.user;

  /// 是否为助手消息
  bool get isAssistant => role == MessageRole.assistant;

  /// 是否为系统消息
  bool get isSystem => role == MessageRole.system;

  /// 是否为工具消息
  bool get isTool => role == MessageRole.tool;

  static MessageRole _parseRole(String? role) {
    switch (role) {
      case 'user':
        return MessageRole.user;
      case 'assistant':
        return MessageRole.assistant;
      case 'system':
        return MessageRole.system;
      case 'tool':
        return MessageRole.tool;
      default:
        return MessageRole.user;
    }
  }
}

/// 消息角色
enum MessageRole {
  user,
  assistant,
  system,
  tool,
}
