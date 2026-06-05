import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../models/distillation.dart';
import '../models/chapter.dart';
import '../services/distillation_service.dart';
import '../services/chapter_service.dart';
import '../services/project_service.dart';
import '../services/ai_engine.dart';

/// 蒸馏页面
class DistillationScreen extends StatefulWidget {
  final String? projectId;

  const DistillationScreen({super.key, this.projectId});

  @override
  State<DistillationScreen> createState() => _DistillationScreenState();
}

class _DistillationScreenState extends State<DistillationScreen> {
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
      body: distillationService.isProcessing
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
                        size: 64,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      Text(
                        '暂无蒸馏任务',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.small),
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
                    color: _getStatusColor(distillation.status, theme),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getStatusIcon(distillation.status),
                    color: theme.colorScheme.onPrimaryContainer,
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
                            label: Text(_getTypeName(distillation.type)),
                            visualDensity: VisualDensity.compact,
                          ),
                          const SizedBox(width: AppSpacing.small),
                          Text(
                            _getStatusText(distillation.status),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: _getStatusColor(distillation.status, theme),
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
                        _showResultDialog(context, distillation);
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
              LinearProgressIndicator(
                value: distillation.progress,
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
                  borderRadius: BorderRadius.circular(8),
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
                  borderRadius: BorderRadius.circular(8),
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

  void _showCreateDialog(
    BuildContext context,
    DistillationService distillationService,
  ) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final promptController = TextEditingController();
    var selectedType = DistillationType.summary;
    DistillationTemplate? selectedTemplate;
    final selectedChapters = <String>[];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
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
                        final template = distillationService.templates
                            .firstWhere(
                              (t) => t.type == selectedType && t.isBuiltIn,
                              orElse: () => distillationService.templates.first,
                            );
                        promptController.text = template.promptTemplate;
                        selectedTemplate = template;
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
                      Consumer<ChapterService>(
                        builder: (context, chapterService, _) {
                          final chapters = chapterService.getChapters(widget.projectId!);
                          if (chapters.isEmpty) {
                            return const Text('该项目暂无章节');
                          }

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
                onPressed: () => Navigator.pop(context),
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

                  if (mounted) Navigator.pop(context);

                  // 询问是否立即开始
                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('开始蒸馏？'),
                        content: const Text('任务已创建，是否立即开始蒸馏？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('稍后'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
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
