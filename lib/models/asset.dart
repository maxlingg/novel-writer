import 'package:uuid/uuid.dart';

/// 素材类型枚举
enum AssetType {
  character,   // 人物
  scene,       // 场景
  item,        // 物品
  concept,     // 概念
  world,       // 世界观
  timeline,    // 时间线
  relation,    // 关系
}

/// 素材可见性
enum AssetVisibility {
  private,     // 私有
  project,     // 项目内可见
  public,      // 公开
}

/// 素材模型
class Asset {
  final String id;
  String name;
  String description;
  AssetType type;
  String content;        // 详细内容
  String? thumbnail;     // 缩略图
  String? tags;          // 标签，逗号分隔
  AssetVisibility visibility;
  String? projectId;     // 关联的项目ID（可选，用于项目级素材）
  int usageCount;        // 使用次数
  DateTime createdAt;
  DateTime updatedAt;
  Map<String, dynamic> metadata;

  Asset({
    String? id,
    required this.name,
    this.description = '',
    required this.type,
    this.content = '',
    this.thumbnail,
    this.tags,
    this.visibility = AssetVisibility.private,
    this.projectId,
    this.usageCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.metadata = const {},
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      content: json['content'] as String? ?? '',
      thumbnail: json['thumbnail'] as String?,
      tags: json['tags'] as String?,
      visibility: _parseVisibility(json['visibility'] as String?),
      projectId: json['projectId'] as String?,
      usageCount: json['usageCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'content': content,
      'thumbnail': thumbnail,
      'tags': tags,
      'visibility': visibility.name,
      'projectId': projectId,
      'usageCount': usageCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  static AssetType _parseType(String? type) {
    switch (type) {
      case 'character':
        return AssetType.character;
      case 'scene':
        return AssetType.scene;
      case 'item':
        return AssetType.item;
      case 'concept':
        return AssetType.concept;
      case 'world':
        return AssetType.world;
      case 'timeline':
        return AssetType.timeline;
      case 'relation':
        return AssetType.relation;
      default:
        return AssetType.character;
    }
  }

  static AssetVisibility _parseVisibility(String? visibility) {
    switch (visibility) {
      case 'project':
        return AssetVisibility.project;
      case 'public':
        return AssetVisibility.public;
      default:
        return AssetVisibility.private;
    }
  }

  Asset copyWith({
    String? name,
    String? description,
    AssetType? type,
    String? content,
    String? thumbnail,
    String? tags,
    AssetVisibility? visibility,
    String? projectId,
    int? usageCount,
    Map<String, dynamic>? metadata,
  }) {
    return Asset(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      content: content ?? this.content,
      thumbnail: thumbnail ?? this.thumbnail,
      tags: tags ?? this.tags,
      visibility: visibility ?? this.visibility,
      projectId: projectId ?? this.projectId,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      metadata: metadata ?? this.metadata,
    );
  }
}

/// 素材分类模型
class AssetCategory {
  final String id;
  String name;
  String? icon;
  int sortOrder;
  DateTime createdAt;

  AssetCategory({
    String? id,
    required this.name,
    this.icon,
    this.sortOrder = 0,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
}

/// 素材关系模型
class AssetRelation {
  final String id;
  String fromAssetId;
  String toAssetId;
  String relationType;    // 关系类型：朋友、敌人、位置等
  String? description;
  DateTime createdAt;

  AssetRelation({
    String? id,
    required this.fromAssetId,
    required this.toAssetId,
    required this.relationType,
    this.description,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();
}
