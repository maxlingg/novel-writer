import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/skill.dart';
import '../services/skill_manager.dart';
import '../utils/constants.dart';

/// 技能市场页面
class SkillMarketplaceScreen extends StatefulWidget {
  const SkillMarketplaceScreen({super.key});

  @override
  State<SkillMarketplaceScreen> createState() => _SkillMarketplaceScreenState();
}

class _SkillMarketplaceScreenState extends State<SkillMarketplaceScreen> {
  String _searchQuery = '';
  String _selectedCategory = '全部';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('技能市场'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: '搜索技能...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        ),
      ),
      body: Consumer<SkillManager>(
        builder: (context, skillManager, child) {
          final skills = skillManager.searchSkills(_searchQuery);

          return Column(
            children: [
              // 分类筛选
              _buildCategoryFilter(skillManager),
              // 技能列表
              Expanded(
                child: skills.isEmpty
                    ? const Center(child: Text('没有找到相关技能'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: skills.length,
                        itemBuilder: (context, index) {
                          return _SkillCard(
                            skill: skills[index],
                            onToggle: (enabled) {
                              skillManager.toggleSkill(
                                skills[index].id,
                                enabled,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter(SkillManager skillManager) {
    final categories = ['全部', '写作', '编辑', '分析', '设定'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final Skill skill;
  final ValueChanged<bool> onToggle;

  const _SkillCard({required this.skill, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(_getIcon(skill.icon)),
        ),
        title: Text(skill.name),
        subtitle: Text(skill.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (skill.isBuiltIn)
              Chip(
                label: const Text('内置', style: TextStyle(fontSize: 11)),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            Switch(
              value: skill.isEnabled,
              onChanged: onToggle,
            ),
          ],
        ),
        onTap: () => _showSkillDetail(context),
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'edit_note':
        return Icons.edit_note;
      case 'chat':
        return Icons.chat;
      case 'analytics':
        return Icons.analytics;
      case 'person':
        return Icons.person;
      case 'public':
        return Icons.public;
      default:
        return Icons.auto_awesome;
    }
  }

  void _showSkillDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(skill.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('分类: ${skill.category}'),
            const SizedBox(height: 8),
            Text('描述: ${skill.description}'),
            const SizedBox(height: 8),
            Text(
              '系统提示词:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                skill.systemPrompt,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
