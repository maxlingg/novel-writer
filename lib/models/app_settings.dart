import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// 应用设置模型
class AppSettings {
  // 主题
  ThemeModeOption themeMode;
  Color accentColor;
  String fontFamily;
  double fontSize;
  double editorFontSize;

  // 编辑器
  bool autoSave;
  int autoSaveInterval;
  bool showWordCount;
  bool showLineNumbers;
  String editorTheme;       // 编辑器配色方案

  // AI
  String defaultModelConfigId;
  int maxContextMessages;
  bool streamResponse;

  // 同步
  bool webdavEnabled;

  // 通用
  String language;

  AppSettings({
    this.themeMode = ThemeModeOption.system,
    this.accentColor = const Color(0xFF6750A4),
    this.fontFamily = '',
    this.fontSize = 14.0,
    this.editorFontSize = 16.0,
    this.autoSave = true,
    this.autoSaveInterval = 30,
    this.showWordCount = true,
    this.showLineNumbers = false,
    this.editorTheme = 'default',
    this.defaultModelConfigId = '',
    this.maxContextMessages = 20,
    this.streamResponse = true,
    this.webdavEnabled = false,
    this.language = 'zh_CN',
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: _parseThemeMode(json['themeMode'] as String?),
      accentColor: _parseColor(json['accentColor'] as int?),
      fontFamily: json['fontFamily'] as String? ?? '',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      editorFontSize: (json['editorFontSize'] as num?)?.toDouble() ?? 16.0,
      autoSave: json['autoSave'] as bool? ?? true,
      autoSaveInterval: json['autoSaveInterval'] as int? ?? 30,
      showWordCount: json['showWordCount'] as bool? ?? true,
      showLineNumbers: json['showLineNumbers'] as bool? ?? false,
      editorTheme: json['editorTheme'] as String? ?? 'default',
      defaultModelConfigId: json['defaultModelConfigId'] as String? ?? '',
      maxContextMessages: json['maxContextMessages'] as int? ?? 20,
      streamResponse: json['streamResponse'] as bool? ?? true,
      webdavEnabled: json['webdavEnabled'] as bool? ?? false,
      language: json['language'] as String? ?? 'zh_CN',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'accentColor': accentColor.value,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'editorFontSize': editorFontSize,
      'autoSave': autoSave,
      'autoSaveInterval': autoSaveInterval,
      'showWordCount': showWordCount,
      'showLineNumbers': showLineNumbers,
      'editorTheme': editorTheme,
      'defaultModelConfigId': defaultModelConfigId,
      'maxContextMessages': maxContextMessages,
      'streamResponse': streamResponse,
      'webdavEnabled': webdavEnabled,
      'language': language,
    };
  }

  static ThemeModeOption _parseThemeMode(String? mode) {
    switch (mode) {
      case 'light':
        return ThemeModeOption.light;
      case 'dark':
        return ThemeModeOption.dark;
      default:
        return ThemeModeOption.system;
    }
  }

  static Color _parseColor(int? value) {
    if (value == null) return const Color(0xFF6750A4);
    return Color(value);
  }

  /// 获取Flutter ThemeMode
  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }

  AppSettings copyWith({
    ThemeModeOption? themeMode,
    Color? accentColor,
    String? fontFamily,
    double? fontSize,
    double? editorFontSize,
    bool? autoSave,
    int? autoSaveInterval,
    bool? showWordCount,
    bool? showLineNumbers,
    String? editorTheme,
    String? defaultModelConfigId,
    int? maxContextMessages,
    bool? streamResponse,
    bool? webdavEnabled,
    String? language,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      editorFontSize: editorFontSize ?? this.editorFontSize,
      autoSave: autoSave ?? this.autoSave,
      autoSaveInterval: autoSaveInterval ?? this.autoSaveInterval,
      showWordCount: showWordCount ?? this.showWordCount,
      showLineNumbers: showLineNumbers ?? this.showLineNumbers,
      editorTheme: editorTheme ?? this.editorTheme,
      defaultModelConfigId: defaultModelConfigId ?? this.defaultModelConfigId,
      maxContextMessages: maxContextMessages ?? this.maxContextMessages,
      streamResponse: streamResponse ?? this.streamResponse,
      webdavEnabled: webdavEnabled ?? this.webdavEnabled,
      language: language ?? this.language,
    );
  }
}
