import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/search_service.dart';
import '../services/project_service.dart';
import '../services/chapter_service.dart';
import '../services/memo_service.dart';
import '../utils/constants.dart';
import '../models/chapter.dart';
import '../models/memo.dart';

/// 搜索页面
class SearchScreen extends StatefulWidget {
  final String? projectId;

  const SearchScreen({super.key, this.projectId});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    final searchService = context.read<SearchService>();

    List<Chapter> chapters = [];
    List<Memo> memos = [];

    if (widget.projectId != null) {
      final projectService = context.read<ProjectService>();
      final loadedChapters = await projectService.loadChapters(widget.projectId!);
      chapters = loadedChapters.whereType<Chapter>().toList();
      final loadedMemos = await context.read<MemoService>().loadMemos(widget.projectId!);
      memos = loadedMemos.whereType<Memo>().toList();
    }

    searchService.search(
      query,
      chapters: chapters,
      memos: memos,
    );
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            hintText: '搜索...',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _performSearch,
          onChanged: _onSearchChanged,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              context.read<SearchService>().clear();
            },
          ),
        ],
      ),
      body: Consumer<SearchService>(
        builder: (context, searchService, child) {
          if (searchService.isSearching) {
            return const Center(child: CircularProgressIndicator());
          }

          if (searchService.currentQuery.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '搜索章节和备忘录',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          final results = searchService.results;
          if (results.isEmpty) {
            return Center(
              child: Text(
                '没有找到 "${searchService.currentQuery}" 的结果',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    result.type == SearchResultType.chapter
                        ? Icons.menu_book
                        : Icons.note,
                  ),
                  title: Text(result.title),
                  subtitle: Text(
                    result.preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    if (result.type == SearchResultType.chapter) {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.editor,
                        arguments: {
                          'projectId': result.projectId,
                          'chapterId': result.id,
                        },
                      );
                    } else if (result.type == SearchResultType.memo) {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.memo,
                        arguments: result.projectId,
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
