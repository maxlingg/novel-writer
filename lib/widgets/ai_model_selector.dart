import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ai_model_config.dart';
import '../services/settings_service.dart';

/// AI模型选择器组件
class AIModelSelector extends StatelessWidget {
  final AIModelConfig? currentModel;
  final ValueChanged<AIModelConfig?> onModelChanged;

  const AIModelSelector({
    super.key,
    required this.currentModel,
    required this.onModelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.smart_toy),
      onPressed: () => _showModelPicker(context),
      tooltip: currentModel?.displayName ?? '选择模型',
    );
  }

  void _showModelPicker(BuildContext context) {
    final settings = context.read<SettingsService>();
    final models = settings.modelConfigs;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '选择AI模型',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            if (models.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text('请先在设置中配置AI模型'),
              )
            else
              ...models.map((model) => RadioListTile<AIModelConfig>(
                    title: Text(model.displayName),
                    subtitle: Text('${model.provider.name} - ${model.modelId}'),
                    value: model,
                    groupValue: currentModel,
                    onChanged: (value) {
                      onModelChanged(value);
                      Navigator.pop(context);
                    },
                  )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
