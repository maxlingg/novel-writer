import 'package:uuid/uuid.dart';

/// 卷模型
class Volume {
  final String id;
  String projectId;
  String title;
  String description;
  int sortOrder;
  DateTime createdAt;
  DateTime updatedAt;

  Volume({
    String? id,
    required this.projectId,
    required this.title,
    this.description = '',
    this.sortOrder = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Volume.fromJson(Map<String, dynamic> json) {
    return Volume(
      id: json['id'] as String?,
      projectId: json['projectId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Volume copyWith({
    String? title,
    String? description,
    int? sortOrder,
  }) {
    return Volume(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
