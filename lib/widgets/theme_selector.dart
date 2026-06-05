import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// 主题选择器组件
class ThemeSelector extends StatelessWidget {
  final ThemeModeOption currentTheme;
  final ValueChanged<ThemeModeOption> onThemeChanged;

  const ThemeSelector({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_getIcon(currentTheme)),
      onPressed: () => _showThemePicker(context),
      tooltip: _getLabel(currentTheme),
    );
  }

  IconData _getIcon(ThemeModeOption theme) {
    switch (theme) {
      case ThemeModeOption.light:
        return Icons.sunny;
      case ThemeModeOption.dark:
        return Icons.nightlight;
      case ThemeModeOption.system:
        return Icons.phone_android;
    }
  }

  String _getLabel(ThemeModeOption theme) {
    switch (theme) {
      case ThemeModeOption.light:
        return '浅色模式';
      case ThemeModeOption.dark:
        return '深色模式';
      case ThemeModeOption.system:
        return '跟随系统';
    }
  }

  void _showThemePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '选择主题模式',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            ...ThemeModeOption.values.map((mode) => RadioListTile<ThemeModeOption>(
                  title: Text(_getLabel(mode)),
                  value: mode,
                  groupValue: currentTheme,
                  onChanged: (value) {
                    if (value != null) {
                      onThemeChanged(value);
                      Navigator.pop(context);
                    }
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}