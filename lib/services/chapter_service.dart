import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/chapter.dart';
import '../utils/file_helper.dart';
import '../utils/html_helper.dart';

/// 章节管理服务
class ChapterService extends ChangeNotifier {
  /// 加载章节
  Future<Chapter?> loadChapter(String projectId, String chapterId) async {
    final filePath = await FileHelper.getChapterFilePath(projectId, chapterId);
    final json = await FileHelper.readJsonFile(filePath);
    if (json == null) return null;
    return Chapter.fromJson(json);
  }

  /// 创建章节
  Future<Chapter> createChapter({
    required String projectId,
    required String title,
    String volumeId = '',
    int sortOrder = 0,
  }) async {
    final chapter = Chapter(
      projectId: projectId,
      volumeId: volumeId,
      title: title,
      sortOrder: sortOrder,
    );

    await saveChapter(chapter);
    return chapter;
  }

  /// 保存章节
  Future<void> saveChapter(Chapter chapter) async {
    final filePath = await FileHelper.getChapterFilePath(
      chapter.projectId,
      chapter.id,
    );

    // 更新纯文本和字数
    chapter.plainText = HtmlHelper.htmlToPlainText(chapter.content);
    chapter.wordCount = HtmlHelper.countWords(chapter.content);

    await FileHelper.writeJsonFile(filePath, chapter.toJson());
    notifyListeners();
  }

  /// 删除章节
  Future<void> deleteChapter(String projectId, String chapterId) async {
    final filePath = await FileHelper.getChapterFilePath(projectId, chapterId);
    await FileHelper.deleteFile(filePath);
    notifyListeners();
  }

  /// 批量保存章节
  Future<void> saveChapters(List<Chapter> chapters) async {
    for (final chapter in chapters) {
      await saveChapter(chapter);
    }
  }

  /// 获取章节纯文本
  Future<String> getChapterPlainText(String projectId, String chapterId) async {
    final chapter = await loadChapter(projectId, chapterId);
    if (chapter == null) return '';
    return chapter.plainText;
  }

  /// 获取项目总字数
  Future<int> getTotalWordCount(String projectId) async {
    final projectDir = await FileHelper.getProjectDirectory(projectId);
    final chaptersDir = Directory('${projectDir.path}/chapters');

    if (!await chaptersDir.exists()) return 0;

    int total = 0;
    final files = await chaptersDir
        .list()
        .where((e) => e is File && e.path.endsWith('.json'))
        .toList();

    for (final file in files) {
      try {
        final content = await (file as File).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        total += json['wordCount'] as int? ?? 0;
      } catch (e) {
        debugPrint('统计字数失败: $e');
      }
    }

    return total;
  }

  /// 导出章节为纯文本
  Future<String> exportChapterAsText(String projectId, String chapterId) async {
    final chapter = await loadChapter(projectId, chapterId);
    if (chapter == null) return '';
    return '${chapter.title}\n\n${chapter.plainText}';
  }

  /// 导出项目所有章节为纯文本
  Future<String> exportProjectAsText(String projectId, List<Chapter> chapters) async {
    final buffer = StringBuffer();
    for (final chapter in chapters) {
      buffer.writeln(chapter.title);
      buffer.writeln('');
      buffer.write(chapter.plainText);
      buffer.writeln('\n');
      buffer.writeln('---');
      buffer.writeln('');
    }
    return buffer.toString();
  }
}
