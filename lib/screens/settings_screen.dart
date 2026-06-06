import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../models/ai_model_config.dart';
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
                onChanged: (value) => settings.setShowWordCount(value),
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
                onTap: () => _showModelConfigPage(context, settings),
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
    final fonts = [
      {'name': '默认', 'value': ''},
      {'name': '宋体', 'value': 'SimSun'},
      {'name': '黑体', 'value': 'SimHei'},
      {'name': '楷体', 'value': 'KaiTi'},
      {'name': '仿宋', 'value': 'FangSong'},
      {'name': '微软雅黑', 'value': 'Microsoft YaHei'},
    ];

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('选择字体'),
        children: fonts.map((font) {
          final isSelected = settings.fontFamily == font['value'];
          return ListTile(
            title: Text(font['name']!),
            trailing: isSelected
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              settings.setFontFamily(font['value']!);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showModelConfigPage(BuildContext context, SettingsService settings) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ModelConfigScreen(settings: settings),
      ),
    );
  }
}

/// AI模型配置页面
class _ModelConfigScreen extends StatefulWidget {
  final SettingsService settings;

  const _ModelConfigScreen({required this.settings});

  @override
  State<_ModelConfigScreen> createState() => _ModelConfigScreenState();
}

class _ModelConfigScreenState extends State<_ModelConfigScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI模型配置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddModelDialog(context),
          ),
        ],
      ),
      body: widget.settings.modelConfigs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.smart_toy_outlined,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '还没有配置AI模型',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击右上角添加模型配置',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddModelDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('添加模型'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: widget.settings.modelConfigs.length,
              itemBuilder: (context, index) {
                final config = widget.settings.modelConfigs[index];
                final isDefault = widget.settings.defaultModelConfig?.id == config.id;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(config.displayName[0]),
                    ),
                    title: Row(
                      children: [
                        Text(config.displayName),
                        if (isDefault)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Chip(
                              label: const Text('默认', style: TextStyle(fontSize: 10)),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text('${AIProviderNames.names[config.provider] ?? config.provider.name}\n${config.modelId}'),
                    isThreeLine: true,
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        if (!isDefault)
                          const PopupMenuItem(value: 'default', child: Text('设为默认')),
                        const PopupMenuItem(value: 'edit', child: Text('编辑')),
                        const PopupMenuItem(value: 'delete', child: Text('删除')),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'default':
                            widget.settings.setDefaultModelConfig(config.id);
                            setState(() {});
                            break;
                          case 'edit':
                            _showEditModelDialog(context, config);
                            break;
                          case 'delete':
                            _confirmDeleteModel(context, config);
                            break;
                        }
                      },
                    ),
                    onTap: () => _showEditModelDialog(context, config),
                  ),
                );
              },
            ),
    );
  }

  void _showAddModelDialog(BuildContext context) {
    _showModelEditorDialog(context, null);
  }

  void _showEditModelDialog(BuildContext context, AIModelConfig config) {
    _showModelEditorDialog(context, config);
  }

  void _showModelEditorDialog(BuildContext context, AIModelConfig? existingConfig) {
    final nameController = TextEditingController(text: existingConfig?.displayName ?? '');
    final modelIdController = TextEditingController(text: existingConfig?.modelId ?? '');
    final apiKeyController = TextEditingController(text: existingConfig?.apiKey ?? '');
    final baseUrlController = TextEditingController(text: existingConfig?.baseUrl ?? '');
    var selectedProvider = existingConfig?.provider ?? AIProviderType.openai;
    var maxTokens = existingConfig?.maxTokens ?? 4096;
    var temperature = existingConfig?.temperature ?? 0.7;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: Text(existingConfig == null ? '添加AI模型' : '编辑AI模型'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<AIProviderType>(
                      value: selectedProvider,
                      decoration: const InputDecoration(labelText: 'AI提供商'),
                      items: AIProviderType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(AIProviderNames.names[type] ?? type.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedProvider = value!);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '显示名称',
                        hintText: '如：我的GPT-4',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: modelIdController,
                      decoration: const InputDecoration(
                        labelText: '模型ID',
                        hintText: '如：gpt-4, claude-3-sonnet',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: apiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'API Key',
                        hintText: '输入你的API密钥',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: baseUrlController,
                      decoration: const InputDecoration(
                        labelText: '自定义API地址（可选）',
                        hintText: '留空使用默认地址',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Max Tokens: '),
                        Expanded(
                          child: Slider(
                            value: maxTokens.toDouble(),
                            min: 256,
                            max: 8192,
                            divisions: 32,
                            label: maxTokens.toString(),
                            onChanged: (value) {
                              setDialogState(() => maxTokens = value.toInt());
                            },
                          ),
                        ),
                        Text('$maxTokens'),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Temperature: '),
                        Expanded(
                          child: Slider(
                            value: temperature,
                            min: 0.0,
                            max: 2.0,
                            divisions: 20,
                            label: temperature.toStringAsFixed(1),
                            onChanged: (value) {
                              setDialogState(() => temperature = value);
                            },
                          ),
                        ),
                        Text(temperature.toStringAsFixed(1)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty || modelIdController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('请填写名称和模型ID')),
                    );
                    return;
                  }

                  if (existingConfig == null) {
                    final config = AIModelConfig(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      displayName: nameController.text,
                      provider: selectedProvider,
                      modelId: modelIdController.text,
                      apiKey: apiKeyController.text,
                      baseUrl: baseUrlController.text,
                      maxTokens: maxTokens,
                      temperature: temperature,
                    );
                    await widget.settings.addModelConfig(config);
                    // 如果是第一个模型，设为默认
                    if (widget.settings.modelConfigs.length == 1) {
                      await widget.settings.setDefaultModelConfig(config.id);
                    }
                  } else {
                    final updated = existingConfig.copyWith(
                      name: nameController.text,
                      displayName: nameController.text,
                      provider: selectedProvider,
                      modelId: modelIdController.text,
                      apiKey: apiKeyController.text,
                      baseUrl: baseUrlController.text,
                      maxTokens: maxTokens,
                      temperature: temperature,
                    );
                    await widget.settings.updateModelConfig(updated);
                  }

                  if (mounted) {
                    Navigator.pop(dialogContext);
                    setState(() {});
                  }
                },
                child: Text(existingConfig == null ? '添加' : '保存'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteModel(BuildContext context, AIModelConfig config) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除模型「${config.displayName}」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            onPressed: () async {
              await widget.settings.removeModelConfig(config.id);
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
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
