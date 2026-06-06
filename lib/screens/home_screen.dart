import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../services/project_service.dart';
import '../widgets/project_card.dart';

/// 主页/项目列表
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    await context.read<ProjectService>().loadProjects();
  }

  Future<void> _createProject() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _CreateProjectDialog(),
    );

    if (result != null && result['name'] != null && (result['name'] as String).isNotEmpty) {
      await context.read<ProjectService>().createProject(
        name: result['name'] as String,
        description: result['description'] as String? ?? '',
        genre: result['genre'] as String? ?? '',
      );
    }
  }

  Future<void> _deleteProject(String projectId, String projectName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除项目'),
        content: Text('确定要删除项目「$projectName」吗？此操作无法撤销。'),
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

    if (confirm == true) {
      await context.read<ProjectService>().deleteProject(projectId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primary),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.assetLibrary);
            },
            tooltip: '素材库',
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.distillation);
            },
            tooltip: '内容蒸馏',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.search);
            },
            tooltip: '搜索',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
            tooltip: '设置',
          ),
        ],
      ),
      body: Consumer<ProjectService>(
        builder: (context, projectService, child) {
          final projects = projectService.projects;

          return AnimatedSwitcher(
            duration: AppConstants.normalAnimation,
            child: projects.isEmpty
                ? Center(
                    key: const ValueKey('empty'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.menu_book_rounded,
                            size: 80,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '还没有项目',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '点击下方按钮创建你的第一个小说项目',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    key: const ValueKey('list'),
                    onRefresh: _loadProjects,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: projects.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return ProjectCard(
                          project: projects[index],
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.project,
                              arguments: projects[index].id,
                            );
                          },
                          onLongPress: () {
                            _deleteProject(
                              projects[index].id,
                              projects[index].name,
                            );
                          },
                        );
                      },
                    ),
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createProject,
        icon: const Icon(Icons.add),
        label: const Text('创建项目'),
      ),
    );
  }
}

/// 创建项目对话框
class _CreateProjectDialog extends StatefulWidget {
  const _CreateProjectDialog();

  @override
  State<_CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<_CreateProjectDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _genreController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('创建新项目'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '项目名称',
              hintText: '输入小说名称',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '简介',
              hintText: '简要描述你的小说',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _genreController,
            decoration: const InputDecoration(
              labelText: '类型',
              hintText: '如：玄幻、都市、科幻',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, {
              'name': _nameController.text,
              'description': _descriptionController.text,
              'genre': _genreController.text,
            });
          },
          child: const Text('创建'),
        ),
      ],
    );
  }
}
