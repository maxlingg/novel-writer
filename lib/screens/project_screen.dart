import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../models/project.dart';
import '../models/volume.dart';
import '../models/chapter.dart';
import '../services/project_service.dart';
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
        title: Text(_project?.name ?? '项目详情'),
        actions: [
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
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'memo', child: Text('备忘录')),
              const PopupMenuItem(value: 'search', child: Text('搜索')),
              const PopupMenuItem(value: 'assets', child: Text('素材库')),
              const PopupMenuItem(value: 'distillation', child: Text('内容蒸馏')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addChapter(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    if (_project == null) {
      return const Center(child: Text('项目不存在'));
    }

    return Column(
      children: [
        // 项目信息卡片
        _buildProjectInfo(),
        const Divider(height: 1),
        // 章节列表
        Expanded(
          child: _chapters.isEmpty
              ? Center(
                  child: Text(
                    '还没有章节',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : ListView.builder(
                  itemCount: _chapters.length,
                  itemBuilder: (context, index) {
                    return ChapterTile(
                      chapter: _chapters[index],
                      onTap: () => _openChapter(_chapters[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProjectInfo() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _project!.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (_project!.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _project!.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(
                label: Text('${_project!.currentWordCount} 字'),
                avatar: const Icon(Icons.edit, size: 16),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text('${_chapters.length} 章'),
                avatar: const Icon(Icons.menu_book, size: 16),
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
