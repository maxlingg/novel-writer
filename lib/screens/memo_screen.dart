import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/memo.dart';
import '../services/memo_service.dart';
import '../utils/constants.dart';

/// 备忘录页面
class MemoScreen extends StatefulWidget {
  final String? projectId;

  const MemoScreen({super.key, this.projectId});

  @override
  State<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends State<MemoScreen> {
  List<Memo> _memos = [];
  String _selectedCategory = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    if (widget.projectId == null) return;

    final memos = await context
        .read<MemoService>()
        .loadMemos(widget.projectId!);

    setState(() {
      _memos = memos;
      _isLoading = false;
    });
  }

  Future<void> _createMemo() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _MemoEditorDialog(),
    );

    if (result != null && widget.projectId != null) {
      await context.read<MemoService>().createMemo(
            projectId: widget.projectId!,
            title: result['title'] as String? ?? '',
            content: result['content'] as String? ?? '',
            category: result['category'] as String? ?? '',
            tags: (result['tags'] as String?)?.split(',').toList() ?? [],
          );
      _loadMemos();
    }
  }

  Future<void> _deleteMemo(Memo memo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除备忘录'),
        content: Text('确定要删除 "${memo.title}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true && widget.projectId != null) {
      await context.read<MemoService>().deleteMemo(
            widget.projectId!,
            memo.id,
          );
      _loadMemos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('备忘录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 搜索备忘录
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _memos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note,
                        size: 64,
                        color: Theme.of(context).disabledColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '还没有备忘录',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '记录角色设定、世界观、灵感等',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _memos.length,
                  itemBuilder: (context, index) {
                    final memo = _memos[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(memo.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (memo.content.isNotEmpty)
                              Text(
                                memo.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (memo.category.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Chip(
                                  label: Text(memo.category,
                                      style: const TextStyle(fontSize: 11)),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteMemo(memo),
                        ),
                        onTap: () => _editMemo(memo),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createMemo,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _editMemo(Memo memo) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _MemoEditorDialog(memo: memo),
    );

    if (result != null) {
      final updated = memo.copyWith(
        title: result['title'] as String?,
        content: result['content'] as String?,
        category: result['category'] as String?,
      );
      await context.read<MemoService>().saveMemo(updated);
      _loadMemos();
    }
  }
}

class _MemoEditorDialog extends StatefulWidget {
  final Memo? memo;

  const _MemoEditorDialog({this.memo});

  @override
  State<_MemoEditorDialog> createState() => _MemoEditorDialogState();
}

class _MemoEditorDialogState extends State<_MemoEditorDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _categoryController;
  late TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.memo?.title ?? '');
    _contentController =
        TextEditingController(text: widget.memo?.content ?? '');
    _categoryController =
        TextEditingController(text: widget.memo?.category ?? '');
    _tagsController =
        TextEditingController(text: widget.memo?.tags.join(', ') ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.memo == null ? '新建备忘录' : '编辑备忘录'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '标题',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '内容',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: '分类',
                hintText: '如：角色、世界观、情节',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: '标签（逗号分隔）',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, {
              'title': _titleController.text,
              'content': _contentController.text,
              'category': _categoryController.text,
              'tags': _tagsController.text,
            });
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
