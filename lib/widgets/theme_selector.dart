import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// 主题选择器组件
class ThemeSelector extends StatelessWidget {
  final ThemeModeOption currentMode;
  final ValueChanged<ThemeModeOption> onModeChanged;

  const ThemeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeModeOption>(
      segments: const [
        ButtonSegment(
          value: ThemeModeOption.system,
          label: Text('系统'),
          icon: Icon(Icons.brightness_auto),
        ),
        ButtonSegment(
          value: ThemeModeOption.light,
          label: Text('浅色'),
          icon: Icon(Icons.light_mode),
        ),
        ButtonSegment(
          value: ThemeModeOption.dark,
          label: Text('深色'),
          icon: Icon(Icons.dark_mode),
        ),
      ],
      selected: {currentMode},
      onSelectionChanged: (selection) {
        onModeChanged(selection.first);
      },
    );
  }
}
