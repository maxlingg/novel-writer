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
  final _titleController = TextEditingController();
  Timer? _autoSaveTimer;
  bool _hasUnsavedChanges = false;
  bool _isLoading = true;
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _loadChapter();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _contentController.dispose();
    _titleController.dispose();
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
        _titleController.text = chapter.title;
        _wordCount = _countWords(chapter.plainText);
        _isLoading = false;
      });

      _contentController.addListener(_onContentChanged);
      _startAutoSave();
    } else {
      setState(() => _isLoading = false);
    }
  }

  int _countWords(String text) {
    if (text.isEmpty) return 0;
    int count = 0;
    // 中文字符
    final chineseChars = RegExp(r'[\u4e00-\u9fff]');
    count += chineseChars.allMatches(text).length;
    // 英文单词
    final withoutChinese = text.replaceAll(RegExp(r'[\u4e00-\u9fff]'), ' ');
    final englishWords = withoutChinese.split(RegExp(r'\s+'));
    count += englishWords.where((w) => w.isNotEmpty).length;
    return count;
  }

  void _onContentChanged() {
    final newWordCount = _countWords(_contentController.text);
    setState(() {
      if (!_hasUnsavedChanges) {
        _hasUnsavedChanges = true;
      }
      _wordCount = newWordCount;
    });
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

    final text = _contentController.text;
    final updated = _chapter!.copyWith(
      content: '<p>${text.replaceAll('\n', '</p>\n<p>')}</p>',
      plainText: text,
      wordCount: _wordCount,
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

  void _insertFormatting(String prefix, String suffix) {
    final selection = _contentController.selection;
    final text = _contentController.text;

    if (selection.isCollapsed) {
      // 没有选中文本，插入格式标记
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$prefix$suffix',
      );
      _contentController.text = newText;
      _contentController.selection = TextSelection.collapsed(
        offset: selection.start + prefix.length,
      );
    } else {
      // 有选中文本，包裹选中内容
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        '$prefix$selectedText$suffix',
      );
      _contentController.text = newText;
      _contentController.selection = TextSelection.collapsed(
        offset: selection.start + prefix.length + selectedText.length + suffix.length,
      );
    }
    _contentController.notifyListeners();
  }

  void _insertLinePrefix(String prefix) {
    final selection = _contentController.selection;
    final text = _contentController.text;

    // 找到当前行的起始位置
    int lineStart = 0;
    if (selection.start > 0) {
      lineStart = text.lastIndexOf('\n', selection.start - 1) + 1;
    }

    // 在行首插入前缀
    final newText = text.replaceRange(lineStart, lineStart, prefix);
    _contentController.text = newText;
    _contentController.selection = TextSelection.collapsed(
      offset: selection.start + prefix.length,
    );
    _contentController.notifyListeners();
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
                    // 标题编辑
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding,
                        vertical: 4,
                      ),
                      child: TextField(
                        controller: _titleController,
                        style: Theme.of(context).textTheme.titleLarge,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '章节标题',
                        ),
                        onChanged: (value) {
                          if (_chapter != null) {
                            _chapter = _chapter!.copyWith(title: value);
                            _hasUnsavedChanges = true;
                          }
                        },
                      ),
                    ),
                    const Divider(height: 1),
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
            onPressed: () => _insertFormatting('**', '**'),
            tooltip: '加粗',
          ),
          IconButton(
            icon: const Icon(Icons.format_italic, size: 20),
            onPressed: () => _insertFormatting('*', '*'),
            tooltip: '斜体',
          ),
          IconButton(
            icon: const Icon(Icons.format_quote, size: 20),
            onPressed: () => _insertLinePrefix('> '),
            tooltip: '引用',
          ),
          const VerticalDivider(width: 1),
          IconButton(
            icon: const Icon(Icons.format_list_bulleted, size: 20),
            onPressed: () => _insertLinePrefix('- '),
            tooltip: '无序列表',
          ),
          IconButton(
            icon: const Icon(Icons.format_list_numbered, size: 20),
            onPressed: () => _insertLinePrefix('1. '),
            tooltip: '有序列表',
          ),
          const VerticalDivider(width: 1),
          IconButton(
            icon: const Icon(Icons.undo, size: 20),
            onPressed: () => _undo(),
            tooltip: '撤销',
          ),
          IconButton(
            icon: const Icon(Icons.redo, size: 20),
            onPressed: () => _redo(),
            tooltip: '重做',
          ),
        ],
      ),
    );
  }

  void _undo() {
    _contentController.text = _contentController.text;
  }

  void _redo() {
    _contentController.text = _contentController.text;
  }

  Widget _buildStatusBar() {
    final settings = context.watch<SettingsService>();
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
          if (settings.showWordCount)
            Text(
              '$_wordCount 字',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (settings.showWordCount)
            const SizedBox(width: 16),
          Text(
            '${_contentController.text.length} 字符',
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
