import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/ai_model_config.dart';
import '../models/webdav_config.dart';
import '../utils/constants.dart';

/// 设置服务 - 使用 SharedPreferences 持久化存储
class SettingsService extends ChangeNotifier {
  SharedPreferences? _prefs;
  AppSettings _settings = AppSettings();
  List<AIModelConfig> _modelConfigs = [];
  WebDAVConfig _webdavConfig = WebDAVConfig();

  AppSettings get settings => _settings;
  WebDAVConfig get webdavConfig => _webdavConfig;
  List<AIModelConfig> get modelConfigs => _modelConfigs;

  /// 初始化设置服务
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
    await _loadModelConfigs();
    await _loadWebDAVConfig();
  }

  /// 加载应用设置
  Future<void> _loadSettings() async {
    if (_prefs == null) return;
    final jsonStr = _prefs!.getString('app_settings');
    if (jsonStr != null) {
      try {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        _settings = AppSettings.fromJson(json);
      } catch (e) {
        debugPrint('加载设置失败: $e');
      }
    }
  }

  /// 保存应用设置
  Future<void> _saveSettings() async {
    if (_prefs == null) return;
    await _prefs!.setString('app_settings', jsonEncode(_settings.toJson()));
    notifyListeners();
  }

  /// 加载AI模型配置列表
  Future<void> _loadModelConfigs() async {
    if (_prefs == null) return;
    final jsonStr = _prefs!.getString('model_configs');
    if (jsonStr != null) {
      try {
        final jsonList = jsonDecode(jsonStr) as List<dynamic>;
        _modelConfigs = jsonList
            .map((e) => AIModelConfig.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('加载模型配置失败: $e');
      }
    }
  }

  /// 保存AI模型配置列表
  Future<void> _saveModelConfigs() async {
    if (_prefs == null) return;
    await _prefs!.setString(
      'model_configs',
      jsonEncode(_modelConfigs.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  /// 加载WebDAV配置
  Future<void> _loadWebDAVConfig() async {
    if (_prefs == null) return;
    final jsonStr = _prefs!.getString('webdav_config');
    if (jsonStr != null) {
      try {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        _webdavConfig = WebDAVConfig.fromJson(json);
      } catch (e) {
        debugPrint('加载WebDAV配置失败: $e');
      }
    }
  }

  /// 保存WebDAV配置
  Future<void> _saveWebDAVConfig() async {
    if (_prefs == null) return;
    await _prefs!.setString('webdav_config', jsonEncode(_webdavConfig.toJson()));
    notifyListeners();
  }

  // ==================== 主题设置 ====================

  /// 获取Flutter ThemeMode
  ThemeMode get themeMode => _settings.flutterThemeMode;

  /// 获取主题模式选项
  ThemeModeOption get themeModeOption => _settings.themeMode;

  /// 获取主题色
  Color get accentColor => _settings.accentColor;

  /// 获取字体
  String get fontFamily => _settings.fontFamily;

  /// 更新主题模式
  Future<void> setThemeMode(ThemeModeOption mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _saveSettings();
  }

  /// 更新主题色
  Future<void> setAccentColor(Color color) async {
    _settings = _settings.copyWith(accentColor: color);
    await _saveSettings();
  }

  /// 更新字体
  Future<void> setFontFamily(String family) async {
    _settings = _settings.copyWith(fontFamily: family);
    await _saveSettings();
  }

  // ==================== 编辑器设置 ====================

  double get editorFontSize => _settings.editorFontSize;
  bool get autoSave => _settings.autoSave;
  int get autoSaveInterval => _settings.autoSaveInterval;
  bool get showWordCount => _settings.showWordCount;

  Future<void> setEditorFontSize(double size) async {
    _settings = _settings.copyWith(editorFontSize: size);
    await _saveSettings();
  }

  Future<void> setAutoSave(bool enabled) async {
    _settings = _settings.copyWith(autoSave: enabled);
    await _saveSettings();
  }

  Future<void> setShowWordCount(bool enabled) async {
    _settings = _settings.copyWith(showWordCount: enabled);
    await _saveSettings();
  }

  // ==================== AI模型配置 ====================

  /// 添加AI模型配置
  Future<void> addModelConfig(AIModelConfig config) async {
    _modelConfigs.add(config);
    await _saveModelConfigs();
  }

  /// 更新AI模型配置
  Future<void> updateModelConfig(AIModelConfig config) async {
    final index = _modelConfigs.indexWhere((c) => c.id == config.id);
    if (index >= 0) {
      _modelConfigs[index] = config;
      await _saveModelConfigs();
    }
  }

  /// 删除AI模型配置
  Future<void> removeModelConfig(String configId) async {
    _modelConfigs.removeWhere((c) => c.id == configId);
    await _saveModelConfigs();
  }

  /// 获取默认模型配置
  AIModelConfig? get defaultModelConfig {
    if (_settings.defaultModelConfigId.isEmpty) {
      return _modelConfigs.isNotEmpty ? _modelConfigs.first : null;
    }
    try {
      return _modelConfigs.firstWhere(
        (c) => c.id == _settings.defaultModelConfigId,
      );
    } catch (_) {
      return _modelConfigs.isNotEmpty ? _modelConfigs.first : null;
    }
  }

  /// 设置默认模型配置
  Future<void> setDefaultModelConfig(String configId) async {
    _settings = _settings.copyWith(defaultModelConfigId: configId);
    await _saveSettings();
  }

  // ==================== WebDAV设置 ====================

  /// 更新WebDAV配置
  Future<void> updateWebDAVConfig(WebDAVConfig config) async {
    _webdavConfig = config;
    await _saveWebDAVConfig();
  }
}
