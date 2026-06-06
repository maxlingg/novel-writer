import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../models/distillation.dart';
import '../services/distillation_service.dart';
import '../services/project_service.dart';
import '../services/ai_engine.dart';
import '../services/chapter_service.dart';

/// 蒸馏页面
class DistillationScreen extends StatefulWidget {
  final String? projectId;

  const DistillationScreen({super.key, this.projectId});

  @override
  State<DistillationScreen> createState() => _DistillationScreenState();
}

class _DistillationScreenState extends State<DistillationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final distillationService = context.read<DistillationService>();
      distillationService.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final distillationService = context.watch<DistillationService>();
    final theme = Theme.of(context);

    // 过滤项目相关的蒸馏
    final filteredDistillations = widget.projectId != null
        ? distillationService.getDistillationsByProject(widget.projectId!)
        : distillationService.distillations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('内容蒸馏'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateDialog(context, distillationService),
          ),
        ],
      ),
      body: Column(
        children: [
          // 模板列表
          if (distillationService.templates.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                AppSpacing.medium,
                AppSpacing.medium,
                AppSpacing.xSmall,
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: AppSpacing.small),
                  Text(
                    '蒸馏模板',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.medium),
                itemCount: distillationService.templates.length,
                itemBuilder: (context, index) =>
                    _buildTemplateCard(context, distillationService.templates[index]),
              ),
            ),
            const Divider(height: 1),
          ],

          // 蒸馏任务列表
          Expanded(
            child: distillationService.isProcessing
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: AppSpacing.medium),
                        Text(
                          '正在蒸馏内容...',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : filteredDistillations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome_outlined,
                              size: 72,
                              color: theme.colorScheme.outline.withOpacity(0.5),
                            ),
                            const SizedBox(height: AppSpacing.medium),
                            Text(
                              '暂无蒸馏任务',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.small),
                            Text(
                              '创建蒸馏任务，使用 AI 提炼内容精华',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.large),
                            ElevatedButton.icon(
                              onPressed: () => _showCreateDialog(context, distillationService),
                              icon: const Icon(Icons.add),
                              label: const Text('创建蒸馏任务'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.medium),
                        itemCount: filteredDistillations.length,
                        itemBuilder: (context, index) => _buildDistillationCard(
                          context,
                          filteredDistillations[index],
                          distillationService,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistillationCard(
    BuildContext context,
    Distillation distillation,
    DistillationService distillationService,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 状态图标
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getStatusColor(distillation.status, theme).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Icon(
                    _getStatusIcon(distillation.status),
                    color: _getStatusColor(distillation.status, theme),
                    size: 22,
                  ),
                ),

                const SizedBox(width: AppSpacing.medium),

                // 标题和描述
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        distillation.name,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xSmall),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              _getStatusText(distillation.status),
                              style: TextStyle(
                                fontSize: 11,
                                color: _getStatusColor(distillation.status, theme),
                              ),
                            ),
                            backgroundColor: _getStatusColor(distillation.status, theme)
                                .withOpacity(0.12),
                            visualDensity: VisualDensity.compact,
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.small),
                          ),
                          const SizedBox(width: AppSpacing.small),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.small,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(AppRadius.small),
                            ),
                            child: Text(
                              _getTypeName(distillation.type),
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 操作菜单
                PopupMenuButton(
                  itemBuilder: (context) => [
                    if (distillation.status == DistillationStatus.idle ||
                        distillation.status == DistillationStatus.pending)
                      const PopupMenuItem(
                        value: 'start',
                        child: ListTile(
                          leading: Icon(Icons.play_arrow),
                          title: Text('开始蒸馏'),
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'view',
                      child: ListTile(
                        leading: Icon(Icons.visibility),
                        title: Text('查看结果'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'export',
                      child: ListTile(
                        leading: Icon(Icons.file_download),
                        title: Text('导出结果'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline),
                        title: Text('删除'),
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'start':
                        _startDistillation(distillation, distillationService);
                        break;
                      case 'view':
                        _showResultDialog(context, distillation, distillationService);
                        break;
                      case 'export':
                        _exportResult(distillation, distillationService);
                        break;
                      case 'delete':
                        _confirmDelete(context, distillation, distillationService);
                        break;
                    }
                  },
                ),
              ],
            ),

            // 进度条（如果正在处理）
            if (distillation.status == DistillationStatus.processing &&
                distillation.progress != null) ...[
              const SizedBox(height: AppSpacing.medium),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.small),
                child: LinearProgressIndicator(
                  value: distillation.progress,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                '${(distillation.progress! * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.labelSmall,
              ),
            ],

            // 错误信息
            if (distillation.status == DistillationStatus.failed &&
                distillation.error != null) ...[
              const SizedBox(height: AppSpacing.medium),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.small),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  distillation.error!,
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],

            // 结果预览
            if (distillation.status == DistillationStatus.completed &&
                distillation.content.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.medium),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.medium),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  distillation.content,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    DistillationTemplate template,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.small),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          onTap: () {
            _showCreateDialog(context, context.read<DistillationService>(),
                preselectedTemplate: template);
          },
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Row(
              children: [
                // 左侧图标
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Icon(
                    _getTypeIcon(template.type),
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                // 右侧标题+描述
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (template.description.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xSmall),
                        Text(
                          template.description,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(DistillationType type) {
    switch (type) {
      case DistillationType.summary:
        return Icons.summarize;
      case DistillationType.outline:
        return Icons.list_alt;
      case DistillationType.character:
        return Icons.person_search;
      case DistillationType.theme:
        return Icons.palette;
      case DistillationType.structure:
        return Icons.account_tree;
      case DistillationType.custom:
        return Icons.tune;
    }
  }

  void _showCreateDialog(
    BuildContext context,
    DistillationService distillationService, {
    DistillationTemplate? preselectedTemplate,
  }) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final promptController = TextEditingController();
    var selectedType = preselectedTemplate?.type ?? DistillationType.summary;
    DistillationTemplate? selectedTemplate = preselectedTemplate;
    final selectedChapters = <String>[];

    // 如果有预选模板，设置提示词
    if (preselectedTemplate != null) {
      promptController.text = preselectedTemplate.promptTemplate;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text('创建蒸馏任务'),
            content: SizedBox(
              width: 600,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<DistillationType>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: '蒸馏类型'),
                      items: DistillationType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getTypeName(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedType = value!);
                        // 查找对应类型的模板
                        final matchingTemplates = distillationService.templates
                            .where((t) => t.type == selectedType && t.isBuiltIn);
                        if (matchingTemplates.isNotEmpty) {
                          final template = matchingTemplates.first;
                          promptController.text = template.promptTemplate;
                          selectedTemplate = template;
                        }
                      },
                    ),

                    if (distillationService.templates
                        .where((t) => t.type == selectedType)
                        .isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.medium),
                      DropdownButtonFormField<DistillationTemplate>(
                        value: selectedTemplate,
                        decoration: const InputDecoration(labelText: '使用模板'),
                        items: distillationService.templates
                            .where((t) => t.type == selectedType)
                            .map((template) {
                          return DropdownMenuItem(
                            value: template,
                            child: Text(template.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() => selectedTemplate = value);
                          if (value != null) {
                            promptController.text = value.promptTemplate;
                          }
                        },
                      ),
                    ],

                    const SizedBox(height: AppSpacing.medium),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: '任务名称'),
                    ),

                    const SizedBox(height: AppSpacing.medium),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: '描述'),
                      maxLines: 2,
                    ),

                    if (widget.projectId != null) ...[
                      const SizedBox(height: AppSpacing.medium),
                      FutureBuilder<List<dynamic>>(
                        future: context.read<ProjectService>().loadChapters(widget.projectId!),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text('该项目暂无章节');
                          }

                          final chapters = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '选择要蒸馏的章节',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: AppSpacing.small),
                              ...chapters.map((chapter) {
                                return CheckboxListTile(
                                  title: Text(chapter.title),
                                  value: selectedChapters.contains(chapter.id),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      if (value == true) {
                                        selectedChapters.add(chapter.id);
                                      } else {
                                        selectedChapters.remove(chapter.id);
                                      }
                                    });
                                  },
                                );
                              }),
                            ],
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: AppSpacing.medium),
                    TextField(
                      controller: promptController,
                      decoration: const InputDecoration(
                        labelText: '自定义提示词（可选）',
                        helperText: '使用 {content} 来表示内容占位符',
                      ),
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) return;

                  final distillation = await distillationService.createDistillation(
                    name: nameController.text,
                    description: descController.text,
                    type: selectedType,
                    projectId: widget.projectId,
                    chapterIds: selectedChapters.isEmpty ? null : selectedChapters,
                    prompt: promptController.text.isEmpty ? null : promptController.text,
                    template: selectedTemplate,
                  );

                  if (mounted) Navigator.pop(dialogContext);

                  // 询问是否立即开始
                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('开始蒸馏？'),
                        content: const Text('任务已创建，是否立即开始蒸馏？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('稍后'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _startDistillation(distillation, distillationService);
                            },
                            child: const Text('开始'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: const Text('创建'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _startDistillation(
    Distillation distillation,
    DistillationService distillationService,
  ) async {
    final aiEngine = context.read<AIEngine>();
    final chapterService = context.read<ChapterService>();
    final projectService = context.read<ProjectService>();

    await distillationService.executeDistillation(
      distillation.id,
      aiEngine: aiEngine,
      chapterService: chapterService,
      projectService: projectService,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('蒸馏完成！')),
      );
    }
  }

  void _showResultDialog(
    BuildContext context,
    Distillation distillation,
    DistillationService distillationService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(distillation.name),
        content: SizedBox(
          width: 700,
          height: 500,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.small),
              child: Text(
                distillation.content.isNotEmpty
                    ? distillation.content
                    : '暂无结果，请先开始蒸馏。',
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          ElevatedButton.icon(
            onPressed: () => _exportResult(distillation, distillationService),
            icon: const Icon(Icons.file_download),
            label: const Text('导出'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportResult(
    Distillation distillation,
    DistillationService distillationService,
  ) async {
    final content = await distillationService.exportDistillation(distillation.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('导出功能开发中...')),
      );
    }
  }

  void _confirmDelete(
    BuildContext context,
    Distillation distillation,
    DistillationService distillationService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除蒸馏任务「${distillation.name}」吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            onPressed: () async {
              await distillationService.deleteDistillation(distillation.id);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(DistillationStatus status) {
    switch (status) {
      case DistillationStatus.idle:
        return Icons.pause_circle_outline;
      case DistillationStatus.pending:
        return Icons.schedule;
      case DistillationStatus.processing:
        return Icons.hourglass_empty;
      case DistillationStatus.completed:
        return Icons.check_circle_outline;
      case DistillationStatus.failed:
        return Icons.error_outline;
    }
  }

  Color _getStatusColor(DistillationStatus status, ThemeData theme) {
    switch (status) {
      case DistillationStatus.idle:
        return theme.colorScheme.outline;
      case DistillationStatus.pending:
        return theme.colorScheme.tertiaryContainer;
      case DistillationStatus.processing:
        return theme.colorScheme.primaryContainer;
      case DistillationStatus.completed:
        return theme.colorScheme.primary;
      case DistillationStatus.failed:
        return theme.colorScheme.error;
    }
  }

  String _getStatusText(DistillationStatus status) {
    switch (status) {
      case DistillationStatus.idle:
        return '空闲';
      case DistillationStatus.pending:
        return '待处理';
      case DistillationStatus.processing:
        return '处理中';
      case DistillationStatus.completed:
        return '已完成';
      case DistillationStatus.failed:
        return '失败';
    }
  }

  String _getTypeName(DistillationType type) {
    switch (type) {
      case DistillationType.summary:
        return '内容摘要';
      case DistillationType.outline:
        return '章节大纲';
      case DistillationType.character:
        return '人物分析';
      case DistillationType.theme:
        return '主题提炼';
      case DistillationType.structure:
        return '结构分析';
      case DistillationType.custom:
        return '自定义';
    }
  }
}
