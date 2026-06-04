import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../models/volume.dart';
import '../models/chapter.dart';
import '../utils/file_helper.dart';

/// 项目管理服务
class ProjectService extends ChangeNotifier {
  final List<Project> _projects = [];
  final Map<String, List<Volume>> _volumes = {};
  final Map<String, List<Chapter>> _chapters = {};

  List<Project> get projects => List.unmodifiable(_projects);

  /// 加载所有项目
  Future<void> loadProjects() async {
    final appDir = await FileHelper.appDirectory;
    final projectsDir = Directory('${appDir.path}/projects');

    if (!await projectsDir.exists()) return;

    _projects.clear();
    _volumes.clear();
    _chapters.clear();

    final dirs = await projectsDir.list().where((e) => e is Directory).toList();
    for (final dir in dirs) {
      final projectFile = File('${dir.path}/project.json');
      if (await projectFile.exists()) {
        try {
          final content = await projectFile.readAsString();
          final json = jsonDecode(content) as Map<String, dynamic>;
          _projects.add(Project.fromJson(json));
        } catch (e) {
          debugPrint('加载项目失败: $e');
        }
      }
    }

    // 按更新时间倒序排列
    _projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();
  }

  /// 创建新项目
  Future<Project> createProject({
    required String name,
    String description = '',
    String genre = '',
  }) async {
    final project = Project(
      name: name,
      description: description,
      genre: genre,
    );

    // 创建项目目录结构
    final projectDir = await FileHelper.getProjectDirectory(project.id);
    await Directory('${projectDir.path}/chapters').create(recursive: true);
    await Directory('${projectDir.path}/memos').create(recursive: true);
    await Directory('${projectDir.path}/chat_sessions').create(recursive: true);

    // 保存项目文件
    await FileHelper.writeJsonFile(
      '${projectDir.path}/project.json',
      project.toJson(),
    );

    _projects.insert(0, project);
    notifyListeners();
    return project;
  }

  /// 更新项目
  Future<void> updateProject(Project project) async {
    final projectDir = await FileHelper.getProjectDirectory(project.id);
    await FileHelper.writeJsonFile(
      '${projectDir.path}/project.json',
      project.toJson(),
    );

    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      _projects[index] = project;
    }
    notifyListeners();
  }

  /// 删除项目
  Future<void> deleteProject(String projectId) async {
    final projectDir = await FileHelper.getProjectDirectory(projectId);
    await FileHelper.deleteDirectory(projectDir.path);

    _projects.removeWhere((p) => p.id == projectId);
    _volumes.remove(projectId);
    _chapters.remove(projectId);
    notifyListeners();
  }

  /// 获取项目
  Project? getProject(String projectId) {
    try {
      return _projects.firstWhere((p) => p.id == projectId);
    } catch (_) {
      return null;
    }
  }

  /// 加载项目的卷列表
  Future<List<Volume>> loadVolumes(String projectId) async {
    final projectDir = await FileHelper.getProjectDirectory(projectId);
    final volumesFile = File('${projectDir.path}/volumes.json');

    if (await volumesFile.exists()) {
      try {
        final content = await volumesFile.readAsString();
        final jsonList = jsonDecode(content) as List<dynamic>;
        _volumes[projectId] = jsonList
            .map((e) => Volume.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('加载卷列表失败: $e');
      }
    }

    return _volumes[projectId] ?? [];
  }

  /// 添加卷
  Future<Volume> addVolume({
    required String projectId,
    required String title,
    String description = '',
  }) async {
    final volumes = _volumes[projectId] ?? [];
    final volume = Volume(
      projectId: projectId,
      title: title,
      description: description,
      sortOrder: volumes.length,
    );

    volumes.add(volume);
    _volumes[projectId] = volumes;
    await _saveVolumes(projectId);
    return volume;
  }

  /// 保存卷列表
  Future<void> _saveVolumes(String projectId) async {
    final projectDir = await FileHelper.getProjectDirectory(projectId);
    final volumes = _volumes[projectId] ?? [];
    await FileHelper.writeJsonFile(
      '${projectDir.path}/volumes.json',
      {'volumes': volumes.map((v) => v.toJson()).toList()},
    );
  }

  /// 更新项目字数统计
  Future<void> updateWordCount(String projectId) async {
    final chapters = await loadChapters(projectId);
    final totalWords = chapters.fold<int>(0, (sum, c) => sum + c.wordCount);

    final project = getProject(projectId);
    if (project != null && project.currentWordCount != totalWords) {
      await updateProject(project.copyWith(currentWordCount: totalWords));
    }
  }

  /// 加载项目的章节列表
  Future<List<Chapter>> loadChapters(String projectId) async {
    final projectDir = await FileHelper.getProjectDirectory(projectId);
    final chaptersDir = Directory('${projectDir.path}/chapters');

    if (!await chaptersDir.exists()) return [];

    final chapters = <Chapter>[];
    final files = await chaptersDir
        .list()
        .where((e) => e is File && e.path.endsWith('.json'))
        .toList();

    for (final file in files) {
      try {
        final content = await (file as File).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        chapters.add(Chapter.fromJson(json));
      } catch (e) {
        debugPrint('加载章节失败: $e');
      }
    }

    chapters.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _chapters[projectId] = chapters;
    return chapters;
  }
}
