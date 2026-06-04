import '../utils/constants.dart';

/// 工具调用模型
class ToolCall {
  final String id;
  String name;
  Map<String, dynamic> arguments;
  ToolCallStatus status;
  String? result;
  String? error;
  DateTime createdAt;
  DateTime? completedAt;

  ToolCall({
    String? id,
    required this.name,
    this.arguments = const {},
    this.status = ToolCallStatus.pending,
    this.result,
    this.error,
    DateTime? createdAt,
    this.completedAt,
  })  : id = id ?? '',
        createdAt = createdAt ?? DateTime.now();

  factory ToolCall.fromJson(Map<String, dynamic> json) {
    return ToolCall(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      arguments: json['arguments'] as Map<String, dynamic>? ?? {},
      status: _parseStatus(json['status'] as String?),
      result: json['result'] as String?,
      error: json['error'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arguments': arguments,
      'status': status.name,
      'result': result,
      'error': error,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// 执行耗时（毫秒）
  int? get durationMs {
    if (completedAt == null) return null;
    return completedAt!.difference(createdAt).inMilliseconds;
  }

  static ToolCallStatus _parseStatus(String? status) {
    switch (status) {
      case 'running':
        return ToolCallStatus.running;
      case 'completed':
        return ToolCallStatus.completed;
      case 'failed':
        return ToolCallStatus.failed;
      default:
        return ToolCallStatus.pending;
    }
  }
}
