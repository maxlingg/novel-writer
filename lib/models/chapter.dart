import 'package:uuid/uuid.dart';
import '../utils/constants.dart';

/// 章节模型
class Chapter {
  final String id;
  String projectId;
  String volumeId;
  String title;
  String content;          // HTML格式内容
  String plainText;        // 纯文本（用于搜索和统计）
  ChapterStatus status;
  int wordCount;
  int sortOrder;
  DateTime createdAt;
  DateTime updatedAt;

  Chapter({
    String? id,
    required this.projectId,
    this.volumeId = '',
    required this.title,
    this.content = '',
    this.plainText = '',
    this.status = ChapterStatus.draft,
    this.wordCount = 0,
    this.sortOrder = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String?,
      projectId: json['projectId'] as String? ?? '',
      volumeId: json['volumeId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      plainText: json['plainText'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
      wordCount: json['wordCount'] as int? ?? 0,
      sortOrder: json['sortOrder'] as int? ?? 0,
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
      'volumeId': volumeId,
      'title': title,
      'content': content,
      'plainText': plainText,
      'status': status.name,
      'wordCount': wordCount,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static ChapterStatus _parseStatus(String? status) {
    switch (status) {
      case 'writing':
        return ChapterStatus.writing;
      case 'completed':
        return ChapterStatus.completed;
      case 'revised':
        return ChapterStatus.revised;
      default:
        return ChapterStatus.draft;
    }
  }

  Chapter copyWith({
    String? projectId,
    String? volumeId,
    String? title,
    String? content,
    String? plainText,
    ChapterStatus? status,
    int? wordCount,
    int? sortOrder,
  }) {
    return Chapter(
      id: id,
      projectId: projectId ?? this.projectId,
      volumeId: volumeId ?? this.volumeId,
      title: title ?? this.title,
      content: content ?? this.content,
      plainText: plainText ?? this.plainText,
      status: status ?? this.status,
      wordCount: wordCount ?? this.wordCount,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
