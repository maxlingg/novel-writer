import 'package:uuid/uuid.dart';

/// 备忘录模型
class Memo {
  final String id;
  String projectId;
  String title;
  String content;
  List<String> tags;
  String category;        // 分类：角色、世界观、情节、灵感等
  DateTime createdAt;
  DateTime updatedAt;

  Memo({
    String? id,
    required this.projectId,
    required this.title,
    this.content = '',
    this.tags = const [],
    this.category = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Memo.fromJson(Map<String, dynamic> json) {
    return Memo(
      id: json['id'] as String?,
      projectId: json['projectId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      category: json['category'] as String? ?? '',
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
      'content': content,
      'tags': tags,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Memo copyWith({
    String? projectId,
    String? title,
    String? content,
    List<String>? tags,
    String? category,
  }) {
    return Memo(
      id: id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
