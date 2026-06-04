import 'package:uuid/uuid.dart';
import '../utils/constants.dart';

/// 项目模型
class Project {
  final String id;
  String name;
  String description;
  ProjectStatus status;
  String coverImagePath;
  String genre;           // 小说类型
  String targetWordCount; // 目标字数
  int currentWordCount;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? lastSyncAt;
  Map<String, dynamic> metadata;

  Project({
    String? id,
    required this.name,
    this.description = '',
    this.status = ProjectStatus.draft,
    this.coverImagePath = '',
    this.genre = '',
    this.targetWordCount = '0',
    this.currentWordCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastSyncAt,
    this.metadata = const {},
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
      coverImagePath: json['coverImagePath'] as String? ?? '',
      genre: json['genre'] as String? ?? '',
      targetWordCount: json['targetWordCount'] as String? ?? '0',
      currentWordCount: json['currentWordCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.parse(json['lastSyncAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.name,
      'coverImagePath': coverImagePath,
      'genre': genre,
      'targetWordCount': targetWordCount,
      'currentWordCount': currentWordCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  static ProjectStatus _parseStatus(String? status) {
    switch (status) {
      case 'writing':
        return ProjectStatus.writing;
      case 'completed':
        return ProjectStatus.completed;
      case 'archived':
        return ProjectStatus.archived;
      default:
        return ProjectStatus.draft;
    }
  }

  Project copyWith({
    String? name,
    String? description,
    ProjectStatus? status,
    String? coverImagePath,
    String? genre,
    String? targetWordCount,
    int? currentWordCount,
    Map<String, dynamic>? metadata,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      genre: genre ?? this.genre,
      targetWordCount: targetWordCount ?? this.targetWordCount,
      currentWordCount: currentWordCount ?? this.currentWordCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastSyncAt: lastSyncAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
