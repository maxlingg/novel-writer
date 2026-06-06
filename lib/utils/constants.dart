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
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double iconSize = 24.0;
}

/// 间距常量
class AppSpacing {
  static const double xSmall = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xLarge = 32.0;
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
  draft,      // 草稿
  writing,    // 写作中
  completed,  // 已完成
  archived,   // 已归档
}

/// 章节状态
enum ChapterStatus {
  draft,      // 草稿
  writing,    // 写作中
  completed,  // 已完成
  revised,    // 已修订
}

/// 工具调用状态
enum ToolCallStatus {
  pending,    // 等待执行
  running,    // 执行中
  completed,  // 已完成
  failed,     // 失败
}

/// 同步状态
enum SyncStatus {
  idle,       // 空闲
  syncing,    // 同步中
  success,    // 同步成功
  error,      // 同步失败
}

/// 主题模式
enum ThemeModeOption {
  system,
  light,
  dark,
}
