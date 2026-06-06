import 'package:flutter/material.dart';

/// 应用常量定义
class AppConstants {
  // 应用信息
  static const String appName = 'Novel Writer';
  static const String appVersion = '1.0.0';
  static const String appDescription = '一款 AI 驱动的小说创作工具';

  // 文件相关
  static const String projectExtension = '.nwp';
  static const String chapterExtension = '.nwc';
  static const String backupExtension = '.nwb';
  static const String exportExtension = '.docx';

  // 数据库/存储
  static const String dbName = 'novel_writer.db';
  static const String settingsPrefix = 'nw_settings_';

  // AI相关
  static const int maxTokens = 4096;
  static const double temperature = 0.7;
  static const int maxChatHistory = 100;
  static const int maxToolCallsPerMessage = 5;

  // WebDAV
  static const String webdavDefaultPath = '/NovelWriter/';

  // 搜索
  static const int searchResultLimit = 50;
  static const int searchDebounceMs = 300;

  // 编辑器
  static const int autoSaveIntervalSeconds = 30;
  static const int minAutoSaveCharacters = 10;

  // UI
  static const double defaultPadding = 20.0;
  static const double cardBorderRadius = 16.0;
  static const double iconSize = 24.0;

  // 动画
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 350);
  static const Duration slowAnimation = Duration(milliseconds: 500);
}

/// 间距常量
class AppSpacing {
  static const double xSmall = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xLarge = 32.0;
  static const double xxLarge = 48.0;
}

/// 圆角常量
class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xLarge = 24.0;
  static const double full = 999.0;
}

/// 阴影常量
class AppShadows {
  static const BoxShadow subtle = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 4,
    offset: Offset(0, 1),
  );
  static const BoxShadow medium = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );
  static const BoxShadow elevated = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );
}

/// 渐变预设
class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFF6750A4), Color(0xFF9C27B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient accent = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient warm = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFE91E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// 路由常量
class AppRoutes {
  static const String home = '/';
  static const String project = '/project';
  static const String editor = '/editor';
  static const String aiChat = '/ai-chat';
  static const String settings = '/settings';
  static const String webdav = '/webdav';
  static const String skillMarketplace = '/skill-marketplace';
  static const String memo = '/memo';
  static const String search = '/search';
  static const String assetLibrary = '/asset-library';
  static const String distillation = '/distillation';
}

/// AI提供商类型
enum AIProviderType {
  anthropic,
  openai,
  deepseek,
  glm,
  kimi,
}

/// AI提供商中文名称映射
class AIProviderNames {
  static const Map<AIProviderType, String> names = {
    AIProviderType.anthropic: 'Anthropic (Claude)',
    AIProviderType.openai: 'OpenAI (GPT)',
    AIProviderType.deepseek: 'DeepSeek',
    AIProviderType.glm: '智谱 (GLM)',
    AIProviderType.kimi: 'Kimi (Moonshot)',
  };
}

/// 项目状态
enum ProjectStatus {
  draft,
  writing,
  completed,
  archived,
}

/// 章节状态
enum ChapterStatus {
  draft,
  writing,
  completed,
  revised,
}

/// 工具调用状态
enum ToolCallStatus {
  pending,
  running,
  completed,
  failed,
}

/// 同步状态
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

/// 主题模式
enum ThemeModeOption {
  system,
  light,
  dark,
}