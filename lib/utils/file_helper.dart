import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// 文件工具类
class FileHelper {
  static const _uuid = Uuid();

  /// 获取应用文档目录
  static Future<Directory> get appDirectory async {
    final dir = await getApplicationDocumentsDirectory();
    final appDir = Directory('${dir.path}/novel_writer');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return appDir;
  }

  /// 获取项目目录
  static Future<Directory> getProjectDirectory(String projectId) async {
    final appDir = await appDirectory;
    final projectDir = Directory('${appDir.path}/projects/$projectId');
    if (!await projectDir.exists()) {
      await projectDir.create(recursive: true);
    }
    return projectDir;
  }

  /// 获取章节文件路径
  static Future<String> getChapterFilePath(
    String projectId,
    String chapterId,
  ) async {
    final projectDir = await getProjectDirectory(projectId);
    return '${projectDir.path}/chapters/$chapterId.json';
  }

  /// 读取文本文件
  static Future<String> readTextFile(String path) async {
    final file = File(path);
    if (!await file.exists()) return '';
    return await file.readAsString();
  }

  /// 写入文本文件
  static Future<void> writeTextFile(String path, String content) async {
    final file = File(path);
    final dir = file.parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    await file.writeAsString(content);
  }

  /// 读取JSON文件
  static Future<Map<String, dynamic>?> readJsonFile(String path) async {
    final content = await readTextFile(path);
    if (content.isEmpty) return null;
    try {
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// 写入JSON文件
  static Future<void> writeJsonFile(
    String path,
    Map<String, dynamic> data,
  ) async {
    final content = const JsonEncoder.withIndent('  ').convert(data);
    await writeTextFile(path, content);
  }

  /// 删除文件
  static Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// 删除目录
  static Future<void> deleteDirectory(String path) async {
    final dir = Directory(path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// 检查文件是否存在
  static Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  /// 检查目录是否存在
  static Future<bool> directoryExists(String path) async {
    return await Directory(path).exists();
  }

  /// 列出目录中的文件
  static Future<List<FileSystemEntity>> listDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) return [];
    return dir.list().toList();
  }

  /// 复制文件
  static Future<void> copyFile(String source, String target) async {
    final sourceFile = File(source);
    if (await sourceFile.exists()) {
      final targetFile = File(target);
      final targetDir = targetFile.parent;
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }
      await sourceFile.copy(target);
    }
  }

  /// 获取文件大小（字节）
  static Future<int> getFileSize(String path) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    return await file.length();
  }

  /// 生成唯一ID
  static String generateId() {
    return _uuid.v4();
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
