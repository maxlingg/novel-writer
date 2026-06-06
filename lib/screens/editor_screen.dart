import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../models/chapter.dart';
import '../services/chapter_service.dart';
import '../services/project_service.dart';
import '../services/settings_service.dart';

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
  DateTime? _lastSavedTime;

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

    if (mounted) {
      setState(() {
        _chapter = updated;
        _hasUnsavedChanges = false;
        _lastSavedTime = DateTime.now();
      });
    }
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

  String _chapterStatusLabel(ChapterStatus status) {
    switch (status) {
      case ChapterStatus.writing:
        return '写作中';
      case ChapterStatus.completed:
        return '已完成';
      case ChapterStatus.revised:
        return '已修订';
      default:
        return '草稿';
    }
  }

  void _showTitleEditDialog() {
    final controller = TextEditingController(text: _chapter?.title ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('编辑标题'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入章节标题',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && _chapter != null) {
                setState(() {
                  _chapter = _chapter!.copyWith(title: newTitle);
                  _hasUnsavedChanges = true;
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _undo() {
    if (_contentController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('撤销功能开发中...')),
      );
    }
  }

  void _redo() {
    if (_contentController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('重做功能开发中...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsService>();

    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_chapter == null) {
      return Scaffold(
        body: Center(child: Text('章节不存在')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            _buildToolbar(theme),
            Divider(height: 1, color: theme.dividerColor.withAlpha(80)),
            Expanded(child: _buildEditor(theme, settings)),
            Divider(height: 1, color: theme.dividerColor.withAlpha(80)),
            _buildStatusBar(theme, settings),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      padding: EdgeInsets.fromLTRB(
          AppSpacing.small, AppSpacing.small, AppSpacing.medium, AppSpacing.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints.tightFor(
                  width: AppSpacing.large,
                  height: AppSpacing.large,
                ),
              ),
              SizedBox(width: AppSpacing.small),
              Expanded(
                child: GestureDetector(
                  onTap: _showTitleEditDialog,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          _chapter!.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: AppSpacing.xSmall),
                      Icon(
                        Icons.edit,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xSmall),
          Padding(
            padding: EdgeInsets.only(left: AppSpacing.large + AppSpacing.small),
            child: Row(
              children: [
                Icon(
                  Icons.text_fields,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 4),
                Text(
                  '$_wordCount 字',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: AppSpacing.small),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.small,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    _chapterStatusLabel(_chapter!.status),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.small),
                if (_hasUnsavedChanges)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '未保存',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.small,
          vertical: AppSpacing.xSmall,
        ),
        child: Row(
          children: [
            ActionChip(
              avatar: Icon(Icons.format_bold, size: 18),
              label: const Text('B'),
              onPressed: () => _insertFormatting('**', '**'),
              visualDensity: VisualDensity.compact,
            ),
            SizedBox(width: AppSpacing.xSmall),
            ActionChip(
              avatar: Icon(Icons.format_italic, size: 18),
              label: const Text('I'),
              onPressed: () => _insertFormatting('*', '*'),
              visualDensity: VisualDensity.compact,
            ),
            SizedBox(width: AppSpacing.xSmall),
            ActionChip(
              avatar: Icon(Icons.format_quote, size: 18),
              label: const Text('"'),
              onPressed: () => _insertLinePrefix('> '),
              visualDensity: VisualDensity.compact,
            ),
            SizedBox(width: AppSpacing.xSmall),
            ActionChip(
              avatar: Icon(Icons.format_list_bulleted, size: 18),
              label: const Text('无序列表'),
              onPressed: () => _insertLinePrefix('- '),
              visualDensity: VisualDensity.compact,
            ),
            SizedBox(width: AppSpacing.xSmall),
            ActionChip(
              avatar: Icon(Icons.format_list_numbered, size: 18),
              label: const Text('有序列表'),
              onPressed: () => _insertLinePrefix('1. '),
              visualDensity: VisualDensity.compact,
            ),
            SizedBox(width: AppSpacing.xSmall),
            ActionChip(
              avatar: Icon(Icons.horizontal_rule, size: 18),
              label: const Text('分隔线'),
              onPressed: () => _insertLinePrefix('---\n'),
              visualDensity: VisualDensity.compact,
            ),
            SizedBox(width: AppSpacing.xSmall),
            ActionChip(
              avatar: Icon(Icons.undo, size: 18),
              label: const Text('撤销'),
              onPressed: _undo,
              visualDensity: VisualDensity.compact,
            ),
            SizedBox(width: AppSpacing.xSmall),
            ActionChip(
              avatar: Icon(Icons.redo, size: 18),
              label: const Text('重做'),
              onPressed: _redo,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor(ThemeData theme, SettingsService settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.large,
        vertical: AppSpacing.medium,
      ),
      child: TextField(
        controller: _contentController,
        maxLines: null,
        expands: true,
        style: TextStyle(
          fontSize: 18,
          height: 1.6,
          color: theme.colorScheme.onSurface,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '开始写作...',
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildStatusBar(ThemeData theme, SettingsService settings) {
    final lastSavedText = _lastSavedTime != null
        ? '${_lastSavedTime!.hour.toString().padLeft(2, '0')}:${_lastSavedTime!.minute.toString().padLeft(2, '0')}'
        : '--:--';

    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.small,
      ),
      child: Row(
        children: [
          if (settings.showWordCount) ...[
            Icon(
              Icons.text_fields,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 4),
            Text(
              '$_wordCount 字',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(width: AppSpacing.small),
            Text(
              '|',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.dividerColor,
              ),
            ),
            SizedBox(width: AppSpacing.small),
          ],
          Icon(
            _hasUnsavedChanges ? Icons.sync : Icons.check_circle_outline,
            size: 14,
            color: _hasUnsavedChanges ? Colors.orange : Colors.green,
          ),
          SizedBox(width: 4),
          Text(
            _hasUnsavedChanges ? '未保存' : '已保存',
            style: theme.textTheme.bodySmall?.copyWith(
              color: _hasUnsavedChanges ? Colors.orange : Colors.green,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.access_time,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 4),
          Text(
            lastSavedText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
