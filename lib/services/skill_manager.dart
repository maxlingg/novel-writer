import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/skill.dart';
import '../utils/file_helper.dart';

/// 技能管理器
class SkillManager extends ChangeNotifier {
  final List<Skill> _skills = [];
  bool _isLoading = false;

  List<Skill> get skills => List.unmodifiable(_skills);
  List<Skill> get enabledSkills => _skills.where((s) => s.isEnabled).toList();
  bool get isLoading => _isLoading;

  /// 初始化内置技能
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 加载自定义技能
      await _loadCustomSkills();

      // 确保内置技能存在
      _ensureBuiltInSkills();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载自定义技能
  Future<void> _loadCustomSkills() async {
    final appDir = await FileHelper.appDirectory;
    final skillsDir = Directory('${appDir.path}/skills');

    if (!await skillsDir.exists()) return;

    final files = await skillsDir
        .list()
        .where((e) => e is File && e.path.endsWith('.json'))
        .toList();

    for (final file in files) {
      try {
        final content = await (file as File).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        final skill = Skill.fromJson(json);
        if (!_skills.any((s) => s.id == skill.id)) {
          _skills.add(skill);
        }
      } catch (e) {
        debugPrint('加载技能失败: $e');
      }
    }
  }

  /// 确保内置技能存在
  void _ensureBuiltInSkills() {
    final builtInSkills = [
      Skill(
        id: 'builtin_continue_writing',
        name: '续写助手',
        description: '根据已有内容智能续写小说',
        category: '写作',
        icon: 'edit_note',
        systemPrompt: '你是一位专业的小说续写助手。请根据已有的小说内容，保持一致的风格、语气和人物设定，自然地续写故事。',
        isBuiltIn: true,
      ),
      Skill(
        id: 'builtin_character_dialogue',
        name: '角色对话生成',
        description: '为角色生成符合性格的对话内容',
        category: '写作',
        icon: 'chat',
        systemPrompt: '你是一位擅长角色对话的写作助手。请根据角色的性格特点、背景和当前情境，生成自然、生动的对话。',
        isBuiltIn: true,
      ),
      Skill(
        id: 'builtin_plot_analysis',
        name: '情节分析',
        description: '分析小说情节结构，提供改进建议',
        category: '分析',
        icon: 'analytics',
        systemPrompt: '你是一位专业的小说情节分析师。请分析当前小说的情节结构、节奏、冲突设置等，并提供具体的改进建议。',
        isBuiltIn: true,
      ),
      Skill(
        id: 'builtin_character_profile',
        name: '角色设定',
        description: '帮助创建和完善角色设定',
        category: '设定',
        icon: 'person',
        systemPrompt: '你是一位专业的角色设定助手。请帮助用户创建详细、立体的角色设定，包括性格、背景、动机、成长弧线等。',
        isBuiltIn: true,
      ),
      Skill(
        id: 'builtin_world_building',
        name: '世界观构建',
        description: '协助构建小说世界观',
        category: '设定',
        icon: 'public',
        systemPrompt: '你是一位专业的世界观构建助手。请帮助用户创建完整、自洽的小说世界观，包括地理、历史、文化、魔法体系等。',
        isBuiltIn: true,
      ),
    ];

    for (final skill in builtInSkills) {
      if (!_skills.any((s) => s.id == skill.id)) {
        _skills.add(skill);
      }
    }
  }

  /// 添加自定义技能
  Future<void> addSkill(Skill skill) async {
    _skills.add(skill);
    await _saveSkill(skill);
    notifyListeners();
  }

  /// 更新技能
  Future<void> updateSkill(Skill skill) async {
    final index = _skills.indexWhere((s) => s.id == skill.id);
    if (index >= 0) {
      _skills[index] = skill;
      await _saveSkill(skill);
      notifyListeners();
    }
  }

  /// 删除自定义技能
  Future<void> deleteSkill(String skillId) async {
    final skill = _skills.firstWhere(
      (s) => s.id == skillId,
      orElse: () => Skill(name: ''),
    );
    if (skill.isBuiltIn) {
      // 内置技能只能禁用，不能删除
      await toggleSkill(skillId, false);
      return;
    }

    _skills.removeWhere((s) => s.id == skillId);
    final appDir = await FileHelper.appDirectory;
    await FileHelper.deleteFile('${appDir.path}/skills/$skillId.json');
    notifyListeners();
  }

  /// 切换技能启用状态
  Future<void> toggleSkill(String skillId, bool? enabled) async {
    final skill = _skills.firstWhere((s) => s.id == skillId);
    final newEnabled = enabled ?? !skill.isEnabled;
    final updated = skill.copyWith(isEnabled: newEnabled);
    await updateSkill(updated);
  }

  /// 保存技能到文件
  Future<void> _saveSkill(Skill skill) async {
    if (skill.isBuiltIn) return; // 内置技能不需要保存到文件
    final appDir = await FileHelper.appDirectory;
    await FileHelper.writeJsonFile(
      '${appDir.path}/skills/${skill.id}.json',
      skill.toJson(),
    );
  }

  /// 搜索技能
  List<Skill> searchSkills(String keyword) {
    if (keyword.isEmpty) return skills;
    final lower = keyword.toLowerCase();
    return _skills.where((s) {
      return s.name.toLowerCase().contains(lower) ||
          s.description.toLowerCase().contains(lower) ||
          s.category.toLowerCase().contains(lower);
    }).toList();
  }

  /// 获取技能
  Skill? getSkill(String skillId) {
    try {
      return _skills.firstWhere((s) => s.id == skillId);
    } catch (_) {
      return null;
    }
  }
}
