import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/memo.dart';
import '../utils/file_helper.dart';

/// 备忘录服务
class MemoService extends ChangeNotifier {
  final Map<String, List<Memo>> _memos = {};

  /// 加载项目的备忘录列表
  Future<List<Memo>> loadMemos(String projectId) async {
    final projectDir = await FileHelper.getProjectDirectory(projectId);
    final memosDir = Directory('${projectDir.path}/memos');

    if (!await memosDir.exists()) return [];

    final memos = <Memo>[];
    final files = await memosDir
        .list()
        .where((e) => e is File && e.path.endsWith('.json'))
        .toList();

    for (final file in files) {
      try {
        final content = await (file as File).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        memos.add(Memo.fromJson(json));
      } catch (e) {
        debugPrint('加载备忘录失败: $e');
      }
    }

    memos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    _memos[projectId] = memos;
    return memos;
  }

  /// 创建备忘录
  Future<Memo> createMemo({
    required String projectId,
    required String title,
    String content = '',
    String category = '',
    List<String> tags = const [],
  }) async {
    final memo = Memo(
      projectId: projectId,
      title: title,
      content: content,
      category: category,
      tags: tags,
    );

    await saveMemo(memo);
    return memo;
  }

  /// 保存备忘录
  Future<void> saveMemo(Memo memo) async {
    final projectDir = await FileHelper.getProjectDirectory(memo.projectId);
    await FileHelper.writeJsonFile(
      '${projectDir.path}/memos/${memo.id}.json',
      memo.toJson(),
    );

    final memos = _memos[memo.projectId] ?? [];
    final index = memos.indexWhere((m) => m.id == memo.id);
    if (index >= 0) {
      memos[index] = memo;
    } else {
      memos.add(memo);
    }
    _memos[memo.projectId] = memos;
    notifyListeners();
  }

  /// 删除备忘录
  Future<void> deleteMemo(String projectId, String memoId) async {
    final projectDir = await FileHelper.getProjectDirectory(projectId);
    final filePath = '${projectDir.path}/memos/$memoId.json';
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }

    _memos[projectId]?.removeWhere((m) => m.id == memoId);
    notifyListeners();
  }

  /// 搜索备忘录
  Future<List<Memo>> searchMemos(
    String projectId,
    String keyword,
  ) async {
    final memos = _memos[projectId] ?? await loadMemos(projectId);
    if (keyword.isEmpty) return memos;

    final lowerKeyword = keyword.toLowerCase();
    return memos.where((memo) {
      return memo.title.toLowerCase().contains(lowerKeyword) ||
          memo.content.toLowerCase().contains(lowerKeyword) ||
          memo.tags.any((tag) => tag.toLowerCase().contains(lowerKeyword));
    }).toList();
  }

  /// 获取所有分类
  Future<List<String>> getCategories(String projectId) async {
    final memos = _memos[projectId] ?? await loadMemos(projectId);
    final categories = memos
        .map((m) => m.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }
}
