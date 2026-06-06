import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/asset.dart';
import '../utils/file_helper.dart';

/// 素材库服务
class AssetService extends ChangeNotifier {
  final List<Asset> _assets = [];
  final List<AssetCategory> _categories = [];
  final List<AssetRelation> _relations = [];

  List<Asset> get assets => List.unmodifiable(_assets);
  List<AssetCategory> get categories => List.unmodifiable(_categories);

  /// 加载素材库
  Future<void> loadAssets({String? projectId}) async {
    final appDir = await FileHelper.appDirectory;
    final assetsDir = Directory('${appDir.path}/assets');

    if (!await assetsDir.exists()) {
      await assetsDir.create(recursive: true);
      return;
    }

    _assets.clear();

    // 扫描素材文件
    final files = await assetsDir.list().toList();
    for (final file in files) {
      if (file is File && file.path.endsWith('.json')) {
        try {
          final json = await FileHelper.readJsonFile(file.path);
          if (json != null) {
            final asset = Asset.fromJson(json);
            // 过滤项目级素材
            if (projectId == null || asset.projectId == projectId || asset.projectId == null) {
              _assets.add(asset);
            }
          }
        } catch (e) {
          debugPrint('加载素材失败: $e');
        }
      }
    }

    notifyListeners();
  }

  /// 创建素材
  Future<Asset> createAsset({
    required String name,
    String description = '',
    required AssetType type,
    String content = '',
    String? thumbnail,
    String? tags,
    AssetVisibility visibility = AssetVisibility.private,
    String? projectId,
    Map<String, dynamic> metadata = const {},
  }) async {
    final asset = Asset(
      name: name,
      description: description,
      type: type,
      content: content,
      thumbnail: thumbnail,
      tags: tags,
      visibility: visibility,
      projectId: projectId,
      metadata: metadata,
    );

    await _saveAsset(asset);
    _assets.add(asset);
    notifyListeners();
    return asset;
  }

  /// 更新素材
  Future<void> updateAsset(Asset asset) async {
    final index = _assets.indexWhere((a) => a.id == asset.id);
    if (index >= 0) {
      _assets[index] = asset;
      await _saveAsset(asset);
      notifyListeners();
    }
  }

  /// 删除素材
  Future<void> deleteAsset(String assetId) async {
    final index = _assets.indexWhere((a) => a.id == assetId);
    if (index < 0) return;
    final appDir = await FileHelper.appDirectory;
    await FileHelper.deleteFile('${appDir.path}/assets/$assetId.json');

    _assets.removeWhere((a) => a.id == assetId);
    notifyListeners();
  }

  /// 获取素材
  Asset? getAsset(String assetId) {
    try {
      return _assets.firstWhere((a) => a.id == assetId);
    } catch (e) {
      return null;
    }
  }

  /// 按类型过滤素材
  List<Asset> getAssetsByType(AssetType type, {String? projectId}) {
    return _assets.where((a) {
      if (a.type != type) return false;
      if (projectId != null) {
        return a.projectId == projectId || a.visibility != AssetVisibility.private;
      }
      return true;
    }).toList();
  }

  /// 搜索素材
  List<Asset> searchAssets(String query, {String? projectId, AssetType? type}) {
    if (query.isEmpty) {
      return type != null ? getAssetsByType(type, projectId: projectId) : _assets;
    }

    final lowerQuery = query.toLowerCase();
    return _assets.where((a) {
      if (type != null && a.type != type) return false;
      if (projectId != null && a.projectId != projectId && a.visibility == AssetVisibility.private) {
        return false;
      }
      return a.name.toLowerCase().contains(lowerQuery) ||
          a.description.toLowerCase().contains(lowerQuery) ||
          (a.tags?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// 增加素材使用次数
  Future<void> incrementUsage(String assetId) async {
    final asset = getAsset(assetId);
    if (asset != null) {
      final updated = asset.copyWith(usageCount: asset.usageCount + 1);
      await updateAsset(updated);
    }
  }

  /// 保存素材到文件
  Future<void> _saveAsset(Asset asset) async {
    final appDir = await FileHelper.appDirectory;
    final assetsDir = Directory('${appDir.path}/assets');
    if (!await assetsDir.exists()) {
      await assetsDir.create(recursive: true);
    }
    await FileHelper.writeJsonFile('${assetsDir.path}/${asset.id}.json', asset.toJson());
  }

  /// 批量导入素材
  Future<void> importAssets(List<Asset> assets) async {
    for (final asset in assets) {
      await _saveAsset(asset);
      if (!_assets.any((a) => a.id == asset.id)) {
        _assets.add(asset);
      }
    }
    notifyListeners();
  }

  /// 按使用次数排序获取素材
  List<Asset> getMostUsedAssets({int limit = 10}) {
    final sorted = List<Asset>.from(_assets)..sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return sorted.take(limit).toList();
  }
}
