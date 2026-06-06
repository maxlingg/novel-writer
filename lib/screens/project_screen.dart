import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../models/project.dart';
import '../models/volume.dart';
import '../models/chapter.dart';
import '../services/project_service.dart';
import '../services/chapter_service.dart';
import '../widgets/chapter_tile.dart';

/// 项目详情页面（卷/章节列表）
class ProjectScreen extends StatefulWidget {
  final String? projectId;

  const ProjectScreen({super.key, this.projectId});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  Project? _project;
  List<Volume> _volumes = [];
  List<Chapter> _chapters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.projectId == null) return;

    final projectService = context.read<ProjectService>();
    _project = projectService.getProject(widget.projectId!);

    if (_project != null) {
      _volumes = await projectService.loadVolumes(widget.projectId!);
      _chapters = await projectService.loadChapters(widget.projectId!);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _addVolume() async {
    if (widget.projectId == null) return;

    final title = await showDialog<String>(
      context: context,
      builder: (context) => const _AddVolumeDialog(),
    );

    if (title != null && title.isNotEmpty) {
      await context.read<ProjectService>().addVolume(
            projectId: widget.projectId!,
            title: title,
          );
      _loadData();
    }
  }

  Future<void> _addChapter({String? volumeId}) async {
    if (widget.projectId == null) return;

    final title = await showDialog<String>(
      context: context,
      builder: (context) => const _AddChapterDialog(),
    );

    if (title != null && title.isNotEmpty) {
      await context.read<ProjectService>().createChapter(
            projectId: widget.projectId!,
            title: title,
            volumeId: volumeId ?? '',
          );
      _loadData();
    }
  }

  Future<void> _deleteChapter(Chapter chapter) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除章节'),
        content: Text('确定要删除章节「${chapter.title}」吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true && widget.projectId != null) {
      await context.read<ChapterService>().deleteChapter(
            widget.projectId!,
            chapter.id,
          );
      _loadData();
    }
  }

  Future<void> _editProjectName() async {
    if (_project == null) return;

    final name = await showDialog<String>(
      context: context,
      builder: (context) => _EditProjectDialog(project: _project!),
    );

    if (name != null && name.isNotEmpty) {
      final updated = _project!.copyWith(name: name);
      await context.read<ProjectService>().updateProject(updated);
      _loadData();
    }
  }

  Future<void> _openChapter(Chapter chapter) async {
    Navigator.pushNamed(
      context,
      AppRoutes.editor,
      arguments: {
        'projectId': widget.projectId,
        'chapterId': chapter.id,
      },
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _project?.name ?? '项目详情',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProjectName,
            tooltip: '编辑项目',
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
            tooltip: 'AI助手',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'memo':
                  Navigator.pushNamed(
                    context,
                    AppRoutes.memo,
                    arguments: widget.projectId,
                  );
                  break;
                case 'search':
                  Navigator.pushNamed(
                    context,
                    AppRoutes.search,
                    arguments: widget.projectId,
                  );
                  break;
                case 'assets':
                  Navigator.pushNamed(
                    context,
                    AppRoutes.assetLibrary,
                    arguments: widget.projectId,
                  );
                  break;
                case 'distillation':
                  Navigator.pushNamed(
                    context,
                    AppRoutes.distillation,
                    arguments: widget.projectId,
                  );
                  break;
                case 'addVolume':
                  _addVolume();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'memo', child: Text('备忘录')),
              const PopupMenuItem(value: 'search', child: Text('搜索')),
              const PopupMenuItem(value: 'assets', child: Text('素材库')),
              const PopupMenuItem(value: 'distillation', child: Text('内容蒸馏')),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'addVolume', child: Text('添加卷')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addChapter(),
        tooltip: '添加章节',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    if (_project == null) {
      return const Center(child: Text('项目不存在'));
    }
    final theme = Theme.of(context);

    return Column(
      children: [
        // 项目信息卡片
        _buildProjectInfo(),
        // 章节列表标题栏
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '目录 (${_chapters.length}章)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => _addChapter(),
                icon: const Icon(Icons.add, size: 20),
                tooltip: '添加章节',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        // 章节列表
        Expanded(
          child: _chapters.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_stories_outlined,
                        size: 80,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      Text(
                        '还没有章节',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.small),
                      Text(
                        '点击下方按钮开始创作吧',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _chapters.length,
                  itemBuilder: (context, index) {
                    return ChapterTile(
                      chapter: _chapters[index],
                      onTap: () => _openChapter(_chapters[index]),
                      onLongPress: () => _deleteChapter(_chapters[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProjectInfo() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _project!.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_project!.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _project!.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ActionChip(
                avatar: Icon(Icons.edit, size: 16, color: theme.colorScheme.onSurfaceVariant),
                label: Text('${_project!.currentWordCount} 字'),
                onPressed: () {},
                visualDensity: VisualDensity.compact,
                side: BorderSide(color: theme.colorScheme.outlineVariant),
                backgroundColor: theme.colorScheme.surface,
              ),
              ActionChip(
                avatar: Icon(Icons.menu_book, size: 16, color: theme.colorScheme.onSurfaceVariant),
                label: Text('${_chapters.length} 章'),
                onPressed: () {},
                visualDensity: VisualDensity.compact,
                side: BorderSide(color: theme.colorScheme.outlineVariant),
                backgroundColor: theme.colorScheme.surface,
              ),
              if (_volumes.isNotEmpty)
                ActionChip(
                  avatar: Icon(Icons.folder, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  label: Text('${_volumes.length} 卷'),
                  onPressed: () {},
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                  backgroundColor: theme.colorScheme.surface,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddVolumeDialog extends StatefulWidget {
  const _AddVolumeDialog();

  @override
  State<_AddVolumeDialog> createState() => _AddVolumeDialogState();
}

class _AddVolumeDialogState extends State<_AddVolumeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加卷'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: '卷名',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('添加'),
        ),
      ],
    );
  }
}

class _AddChapterDialog extends StatefulWidget {
  const _AddChapterDialog();

  @override
  State<_AddChapterDialog> createState() => _AddChapterDialogState();
}

class _AddChapterDialogState extends State<_AddChapterDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加章节'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: '章节标题',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('添加'),
        ),
      ],
    );
  }
}

class _EditProjectDialog extends StatefulWidget {
  final Project project;

  const _EditProjectDialog({required this.project});

  @override
  State<_EditProjectDialog> createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<_EditProjectDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
    _descController = TextEditingController(text: widget.project.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑项目'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '项目名称',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: '简介',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _nameController.text),
          child: const Text('保存'),
        ),
      ],
    );
  }
}
