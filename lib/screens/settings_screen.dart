import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../services/settings_service.dart';
import '../widgets/theme_selector.dart';

/// 设置页面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: Consumer<SettingsService>(
        builder: (context, settings, child) {
          return ListView(
            children: [
              // 外观设置
              _SectionHeader(title: '外观'),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('主题模式'),
                subtitle: Text(_themeModeLabel(settings.themeModeOption)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeModeDialog(context, settings),
              ),
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('主题色'),
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: settings.accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () => _showColorPicker(context, settings),
              ),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('字体'),
                subtitle: Text(settings.fontFamily.isEmpty
                    ? '默认'
                    : settings.fontFamily),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showFontPicker(context, settings),
              ),

              const Divider(),

              // 编辑器设置
              _SectionHeader(title: '编辑器'),
              SwitchListTile(
                secondary: const Icon(Icons.save),
                title: const Text('自动保存'),
                subtitle: Text('每 ${settings.autoSaveInterval} 秒自动保存'),
                value: settings.autoSave,
                onChanged: (value) => settings.setAutoSave(value),
              ),
              ListTile(
                leading: const Icon(Icons.format_size),
                title: const Text('编辑器字号'),
                subtitle: Text('${settings.editorFontSize.toInt()}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => settings.setEditorFontSize(
                        (settings.editorFontSize - 1).clamp(12.0, 32.0),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => settings.setEditorFontSize(
                        (settings.editorFontSize + 1).clamp(12.0, 32.0),
                      ),
                    ),
                  ],
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.show_chart),
                title: const Text('显示字数统计'),
                value: settings.showWordCount,
                onChanged: (value) {
                  // TODO: 更新设置
                },
              ),

              const Divider(),

              // AI设置
              _SectionHeader(title: 'AI 模型'),
              ListTile(
                leading: const Icon(Icons.smart_toy),
                title: const Text('AI模型配置'),
                subtitle: Text(
                  settings.modelConfigs.isEmpty
                      ? '未配置'
                      : '${settings.modelConfigs.length} 个模型',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showModelConfigPage(context),
              ),

              const Divider(),

              // 同步设置
              _SectionHeader(title: '同步'),
              ListTile(
                leading: const Icon(Icons.cloud),
                title: const Text('WebDAV 同步'),
                subtitle: Text(
                  settings.webdavConfig.isConfigured ? '已配置' : '未配置',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.webdav);
                },
              ),

              const Divider(),

              // 关于
              _SectionHeader(title: '关于'),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('版本'),
                subtitle: Text(AppConstants.appVersion),
              ),
            ],
          );
        },
      ),
    );
  }

  String _themeModeLabel(ThemeModeOption mode) {
    switch (mode) {
      case ThemeModeOption.system:
        return '跟随系统';
      case ThemeModeOption.light:
        return '浅色';
      case ThemeModeOption.dark:
        return '深色';
    }
  }

  void _showThemeModeDialog(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('选择主题模式'),
        children: ThemeModeOption.values
            .map((mode) => RadioListTile<ThemeModeOption>(
                  title: Text(_themeModeLabel(mode)),
                  value: mode,
                  groupValue: settings.themeModeOption,
                  onChanged: (value) {
                    if (value != null) {
                      settings.setThemeMode(value);
                      Navigator.pop(context);
                    }
                  },
                ))
            .toList(),
      ),
    );
  }

  void _showColorPicker(BuildContext context, SettingsService settings) {
    // TODO: 实现颜色选择器
    final colors = [
      const Color(0xFF6750A4),
      const Color(0xFFE91E63),
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF795548),
    ];

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('选择主题色'),
        children: colors
            .map((color) => ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text('#${color.value.toRadixString(16).toUpperCase()}'),
                  onTap: () {
                    settings.setAccentColor(color);
                    Navigator.pop(context);
                  },
                ))
            .toList(),
      ),
    );
  }

  void _showFontPicker(BuildContext context, SettingsService settings) {
    // TODO: 实现字体选择器
  }

  void _showModelConfigPage(BuildContext context) {
    // TODO: 导航到模型配置页面
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
