import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../models/chapter.dart';
import '../services/chapter_service.dart';
import '../services/project_service.dart';
import '../services/settings_service.dart';
import '../widgets/custom_app_bar.dart';

/// 编辑器页面
class EditorScreen extends StatefulWidget {
  final String projectId;
  final String chapterId;

  const EditorScreen({
    super.key,
    required this.projectId,
    required this.chapterId,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  Chapter? _chapter;
  final _contentController = TextEditingController();
  Timer? _autoSaveTimer;
  bool _hasUnsavedChanges = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChapter();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadChapter() async {
    final chapter = await context
        .read<ChapterService>()
        .loadChapter(widget.projectId, widget.chapterId);

    if (chapter != null) {
      setState(() {
        _chapter = chapter;
        _contentController.text = chapter.plainText;
        _isLoading = false;
      });

      _contentController.addListener(_onContentChanged);
      _startAutoSave();
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _onContentChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  void _startAutoSave() {
    final settings = context.read<SettingsService>();
    if (settings.autoSave) {
      _autoSaveTimer = Timer.periodic(
        Duration(seconds: settings.autoSaveInterval),
        (_) => _saveContent(),
      );
    }
  }

  Future<void> _saveContent() async {
    if (_chapter == null || !_hasUnsavedChanges) return;

    final updated = _chapter!.copyWith(
      content: '<p>${_contentController.text}</p>',
    );

    await context.read<ChapterService>().saveChapter(updated);
    await context
        .read<ProjectService>()
        .updateWordCount(widget.projectId);

    setState(() {
      _chapter = updated;
      _hasUnsavedChanges = false;
    });
  }

  Future<void> _manualSave() async {
    await _saveContent();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _chapter?.title ?? '编辑器',
        actions: [
          if (_hasUnsavedChanges)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  '未保存',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _manualSave,
          ),
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.aiChat,
                arguments: widget.projectId,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chapter == null
              ? const Center(child: Text('章节不存在'))
              : Column(
                  children: [
                    // 工具栏
                    _buildToolbar(),
                    // 编辑区域
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        maxLines: null,
                        expands: true,
                        style: TextStyle(
                          fontSize: context
                              .watch<SettingsService>()
                              .editorFontSize,
                          height: 1.8,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '开始写作...',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppConstants.defaultPadding,
                            vertical: AppConstants.defaultPadding,
                          ),
                        ),
                      ),
                    ),
                    // 底部状态栏
                    _buildStatusBar(),
                  ],
                ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 44,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.format_bold, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.format_italic, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.format_quote, size: 20),
            onPressed: () {},
          ),
          const VerticalDivider(width: 1),
          IconButton(
            icon: const Icon(Icons.format_list_bulleted, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.format_list_numbered, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${_contentController.text.length} 字',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          Text(
            _hasUnsavedChanges ? '未保存' : '已保存',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _hasUnsavedChanges ? Colors.orange : Colors.green,
                ),
          ),
        ],
      ),
    );
  }
}
