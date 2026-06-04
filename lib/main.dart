import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/settings_service.dart';
import 'services/project_service.dart';
import 'services/chapter_service.dart';
import 'services/memo_service.dart';
import 'services/ai_engine.dart';
import 'services/ai_model_provider.dart';
import 'services/tool_registry.dart';
import 'services/skill_manager.dart';
import 'services/webdav_service.dart';
import 'services/search_service.dart';
import 'services/docx_exporter.dart';
import 'services/docx_importer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化设置服务
  final settingsService = SettingsService();
  await settingsService.init();

  // 初始化项目服务
  final projectService = ProjectService();

  // 初始化章节服务
  final chapterService = ChapterService();

  // 初始化备忘录服务
  final memoService = MemoService();

  // 初始化AI引擎
  final aiEngine = AIEngine();

  // 初始化工具注册表
  final toolRegistry = ToolRegistry();

  // 初始化技能管理器
  final skillManager = SkillManager();

  // 初始化WebDAV服务
  final webdavService = WebDAVService();

  // 初始化搜索服务
  final searchService = SearchService();

  // 初始化DOCX导出器
  final docxExporter = DocxExporter();

  // 初始化DOCX导入器
  final docxImporter = DocxImporter();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => settingsService),
        ChangeNotifierProvider(create: (_) => projectService),
        ChangeNotifierProvider(create: (_) => chapterService),
        ChangeNotifierProvider(create: (_) => memoService),
        ChangeNotifierProvider(create: (_) => aiEngine),
        ChangeNotifierProvider(create: (_) => toolRegistry),
        ChangeNotifierProvider(create: (_) => skillManager),
        ChangeNotifierProvider(create: (_) => webdavService),
        ChangeNotifierProvider(create: (_) => searchService),
        Provider(create: (_) => docxExporter),
        Provider(create: (_) => docxImporter),
      ],
      child: const NovelWriterApp(),
    ),
  );
}
