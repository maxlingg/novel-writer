import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chapter.dart';
import '../models/memo.dart';
import '../utils/constants.dart';

/// 搜索服务
class SearchService extends ChangeNotifier {
  Timer? _debounceTimer;
  String _currentQuery = '';
  List<SearchResult> _results = [];
  bool _isSearching = false;

  String get currentQuery => _currentQuery;
  List<SearchResult> get results => List.unmodifiable(_results);
  bool get isSearching => _isSearching;

  /// 搜索项目内容
  void search(String query, {
    List<Chapter>? chapters,
    List<Memo>? memos,
  }) {
    _currentQuery = query;

    // 防抖处理
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () => _performSearch(query, chapters: chapters, memos: memos),
    );
  }

  /// 执行搜索
  void _performSearch(
    String query, {
    List<Chapter>? chapters,
    List<Memo>? memos,
  }) {
    if (query.isEmpty) {
      _results.clear();
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    final results = <SearchResult>[];
    final lowerQuery = query.toLowerCase();

    // 搜索章节
    if (chapters != null) {
      for (final chapter in chapters) {
        if (chapter.title.toLowerCase().contains(lowerQuery) ||
            chapter.plainText.toLowerCase().contains(lowerQuery)) {
          results.add(SearchResult(
            type: SearchResultType.chapter,
            id: chapter.id,
            title: chapter.title,
            preview: _getPreview(chapter.plainText, lowerQuery),
            projectId: chapter.projectId,
          ));

          if (results.length >= AppConstants.searchResultLimit) break;
        }
      }
    }

    // 搜索备忘录
    if (memos != null) {
      for (final memo in memos) {
        if (memo.title.toLowerCase().contains(lowerQuery) ||
            memo.content.toLowerCase().contains(lowerQuery)) {
          results.add(SearchResult(
            type: SearchResultType.memo,
            id: memo.id,
            title: memo.title,
            preview: _getPreview(memo.content, lowerQuery),
            projectId: memo.projectId,
          ));

          if (results.length >= AppConstants.searchResultLimit) break;
        }
      }
    }

    _results = results;
    _isSearching = false;
    notifyListeners();
  }

  /// 获取匹配文本的预览
  String _getPreview(String text, String query) {
    final index = text.toLowerCase().indexOf(query);
    if (index < 0) {
      return text.length > 100 ? '${text.substring(0, 100)}...' : text;
    }

    final start = index > 30 ? index - 30 : 0;
    final end = index + query.length + 70;
    final preview = text.substring(
      start,
      end > text.length ? text.length : end,
    );

    return (start > 0 ? '...' : '') + preview + (end < text.length ? '...' : '');
  }

  /// 清除搜索结果
  void clear() {
    _currentQuery = '';
    _results.clear();
    _isSearching = false;
    _debounceTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// 搜索结果
class SearchResult {
  final SearchResultType type;
  final String id;
  final String title;
  final String preview;
  final String projectId;

  SearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.preview,
    required this.projectId,
  });
}

/// 搜索结果类型
enum SearchResultType {
  chapter,
  memo,
}
