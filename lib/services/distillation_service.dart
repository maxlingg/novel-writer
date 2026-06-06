import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/distillation.dart';
import '../models/chapter.dart';
import '../utils/file_helper.dart';
import 'ai_engine.dart';
import 'chapter_service.dart';
import 'project_service.dart';

/// 蒸馏服务
class DistillationService extends ChangeNotifier {
  final List<Distillation> _distillations = [];
  final List<DistillationTemplate> _templates = [];
  bool _isProcessing = false;

  List<Distillation> get distillations => List.unmodifiable(_distillations);
  List<DistillationTemplate> get templates => List.unmodifiable(_templates);
  bool get isProcessing => _isProcessing;

  /// 初始化内置模板
  Future<void> initialize() async {
    await _loadTemplates();
    await _loadDistillations();
    _initDefaultTemplates();
  }

  /// 初始化默认模板
  void _initDefaultTemplates() {
    final defaultTemplates = [
      DistillationTemplate(
        name: '内容摘要',
        description: '生成章节或项目的内容摘要',
        type: DistillationType.summary,
        promptTemplate: '''请为以下内容生成一个简洁明了的摘要：

{content}

要求：
1. 摘要长度在300-500字
2. 包含主要情节和关键人物
3. 突出核心主题''',
        isBuiltIn: true,
      ),
      DistillationTemplate(
        name: '章节大纲',
        description: '将章节内容提炼为结构化大纲',
        type: DistillationType.outline,
        promptTemplate: '''请将以下内容整理为大纲：

{content}

要求：
1. 分章节/分段整理
2. 每个节点层级分明
3. 包含主要时间点标注''',
        isBuiltIn: true,
      ),
      DistillationTemplate(
        name: '人物分析',
        description: '分析并提炼人物形象特点',
        type: DistillationType.character,
        promptTemplate: '''分析以下内容中的人物：

{content}

请从以下角度分析：
1. 人物基本信息
2. 性格特点
3. 行为动机
4. 人物关系''',
        isBuiltIn: true,
      ),
      DistillationTemplate(
        name: '主题分析',
        description: '提炼核心主题和深层意义',
        type: DistillationType.theme,
        promptTemplate: '''分析以下内容的主题：

{content}

请提供：
1. 核心主题
2. 深层含义
3. 现实映射''',
        isBuiltIn: true,
      ),
      DistillationTemplate(
        name: '结构分析',
        description: '分析文本结构和叙事技巧',
        type: DistillationType.structure,
        promptTemplate: '''分析以下内容的叙事结构：

{content}

请分析：
1. 整体结构
2. 叙事技巧
3. 节奏把控''',
        isBuiltIn: true,
      ),
    ];

    for (final template in defaultTemplates) {
      if (!_templates.any((t) => t.name == template.name)) {
        _templates.add(template);
      }
    }
  }

  /// 创建蒸馏任务
  Future<Distillation> createDistillation({
    required String name,
    String description = '',
    required DistillationType type,
    String? projectId,
    List<String>? chapterIds,
    String? prompt,
    DistillationTemplate? template,
    Map<String, dynamic>? config,
  }) async {
    final distillation = Distillation(
      name: name,
      description: description,
      type: type,
      projectId: projectId,
      chapterIds: chapterIds,
      prompt: prompt ?? template?.promptTemplate,
      config: config ?? template?.defaultConfig,
      status: DistillationStatus.pending,
    );

    _distillations.add(distillation);
    await _saveDistillation(distillation);
    notifyListeners();
    return distillation;
  }

  /// 执行蒸馏
  Future<void> executeDistillation(
    String distillationId, {
    required AIEngine aiEngine,
    required ChapterService chapterService,
    required ProjectService projectService,
  }) async {
    final index = _distillations.indexWhere((d) => d.id == distillationId);
    if (index < 0) {
      _isProcessing = false;
      notifyListeners();
      return;
    }
    final distillation = _distillations[index];

    _isProcessing = true;
    notifyListeners();

    try {
      // 更新状态为处理中
      final updated = distillation.copyWith(
        status: DistillationStatus.processing,
        startedAt: DateTime.now(),
        progress: 0.0,
      );
      await updateDistillation(updated);

      // 收集内容
      final contentBuffer = StringBuffer();
      if (distillation.chapterIds?.isNotEmpty ?? false) {
        for (final chapterId in distillation.chapterIds!) {
          final chapter = await chapterService.loadChapter(
            distillation.projectId!,
            chapterId,
          );
          if (chapter != null) {
            contentBuffer.writeln('=== ${chapter.title} ===');
            contentBuffer.writeln(chapter.plainText);
            contentBuffer.writeln();
          }
        }
      }

      // 构建提示词
      var finalPrompt = distillation.prompt ?? '';
      finalPrompt = finalPrompt.replaceAll('{content}', contentBuffer.toString());

      // 模拟进度
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        final progress = distillation.copyWith(progress: i * 0.1);
        await updateDistillation(progress);
      }

      // 模拟结果（实际应该调用AI）
      final resultContent = '''【${distillation.name}】

本功能需要配置AI模型后使用。

当前收集的内容长度：${contentBuffer.length} 字符

提示词示例：
- 摘要内容将在这里生成...''';

      // 完成
      final completed = distillation.copyWith(
        status: DistillationStatus.completed,
        content: resultContent,
        progress: 1.0,
        completedAt: DateTime.now(),
      );
      await updateDistillation(completed);
    } catch (e) {
      // 失败
      final failed = distillation.copyWith(
        status: DistillationStatus.failed,
        error: e.toString(),
      );
      await updateDistillation(failed);
      debugPrint('蒸馏失败: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// 更新蒸馏
  Future<void> updateDistillation(Distillation distillation) async {
    final index = _distillations.indexWhere((d) => d.id == distillation.id);
    if (index >= 0) {
      _distillations[index] = distillation;
      await _saveDistillation(distillation);
      notifyListeners();
    }
  }

  /// 删除蒸馏
  Future<void> deleteDistillation(String distillationId) async {
    _distillations.removeWhere((d) => d.id == distillationId);
    final appDir = await FileHelper.appDirectory;
    await FileHelper.deleteFile('${appDir.path}/distillations/$distillationId.json');
    notifyListeners();
  }

  /// 获取蒸馏
  Distillation? getDistillation(String distillationId) {
    try {
      return _distillations.firstWhere((d) => d.id == distillationId);
    } catch (e) {
      return null;
    }
  }

  /// 获取项目的蒸馏列表
  List<Distillation> getDistillationsByProject(String projectId) {
    return _distillations.where((d) => d.projectId == projectId).toList();
  }

  /// 保存蒸馏到文件
  Future<void> _saveDistillation(Distillation distillation) async {
    final appDir = await FileHelper.appDirectory;
    final distDir = Directory('${appDir.path}/distillations');
    if (!await distDir.exists()) {
      await distDir.create(recursive: true);
    }
    await FileHelper.writeJsonFile(
      '${distDir.path}/${distillation.id}.json',
      distillation.toJson(),
    );
  }

  /// 加载蒸馏列表
  Future<void> _loadDistillations() async {
    final appDir = await FileHelper.appDirectory;
    final distDir = Directory('${appDir.path}/distillations');

    if (!await distDir.exists()) return;

    _distillations.clear();
    final files = await distDir.list().toList();

    for (final file in files) {
      if (file is File && file.path.endsWith('.json')) {
        try {
          final json = await FileHelper.readJsonFile(file.path);
          if (json != null) {
            _distillations.add(Distillation.fromJson(json));
          }
        } catch (e) {
          debugPrint('加载蒸馏失败: $e');
        }
      }
    }
  }

  /// 加载模板
  Future<void> _loadTemplates() async {
    // 模板暂时存储在SharedPreferences或内置
  }

  /// 导出蒸馏结果
  Future<String> exportDistillation(String distillationId) async {
    final distillation = getDistillation(distillationId);
    if (distillation == null) return '';

    return '''# ${distillation.name}

${distillation.description}

---

${distillation.content}

---

*生成时间: ${distillation.completedAt?.toLocal()}*
''';
  }

  /// 创建自定义模板
  Future<DistillationTemplate> createTemplate({
    required String name,
    String description = '',
    required DistillationType type,
    required String promptTemplate,
    Map<String, dynamic> defaultConfig = const {},
  }) async {
    final template = DistillationTemplate(
      name: name,
      description: description,
      type: type,
      promptTemplate: promptTemplate,
      defaultConfig: defaultConfig,
      isBuiltIn: false,
    );
    _templates.add(template);
    notifyListeners();
    return template;
  }
}
