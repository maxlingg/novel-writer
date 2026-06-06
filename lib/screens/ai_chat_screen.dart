import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../models/ai_model_config.dart';
import '../services/ai_engine.dart';
import '../services/settings_service.dart';
import '../services/skill_manager.dart';
import '../services/tool_registry.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/tool_call_card.dart';
import '../widgets/ai_model_selector.dart';

/// AI聊天页面
class AIChatScreen extends StatefulWidget {
  final String? projectId;

  const AIChatScreen({super.key, this.projectId});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  ChatSession? _currentSession;
  AIModelConfig? _selectedModel;
  bool _isLoadingSession = true;

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initSession() async {
    final settings = context.read<SettingsService>();
    _selectedModel = settings.defaultModelConfig;

    _currentSession = ChatSession(
      projectId: widget.projectId ?? '',
    );

    setState(() => _isLoadingSession = false);
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (_selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请先配置AI模型'),
          action: SnackBarAction(
            label: '去设置',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ),
      );
      return;
    }

    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(
        sessionId: _currentSession!.id,
        role: MessageRole.user,
        content: text,
      ));
    });

    _scrollToBottom();

    final aiEngine = context.read<AIEngine>();
    final responses = await aiEngine.sendMessage(
      session: _currentSession!,
      userMessage: text,
      modelConfig: _selectedModel!,
      history: _messages,
    );

    if (mounted) {
      setState(() {
        _messages.addAll(responses.where((r) => r.role != MessageRole.user));
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _newSession() async {
    setState(() {
      _messages.clear();
      _currentSession = ChatSession(
        projectId: widget.projectId ?? '',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: _newSession,
            tooltip: '新对话',
          ),
        ],
      ),
      body: Column(
        children: [
          // 顶部模型选择器
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.medium,
              vertical: AppSpacing.small,
            ),
            color: theme.colorScheme.surfaceContainerLow,
            child: AIModelSelector(
              currentModel: _selectedModel,
              onModelChanged: (model) {
                setState(() => _selectedModel = model);
              },
            ),
          ),
          // 消息列表
          Expanded(
            child: _isLoadingSession
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 64,
                              color: theme.colorScheme.primary.withOpacity(0.4),
                            ),
                            const SizedBox(height: AppSpacing.medium),
                            Text(
                              '开始对话',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.small),
                            Text(
                              '可以询问写作建议、角色设定、情节构思等',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Listener(
                        onPointerMove: (_) {},
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppSpacing.medium),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            return Column(
                              children: [
                                ChatBubble(message: message),
                                // 显示工具调用卡片
                                if (message.toolCalls != null)
                                  ...message.toolCalls!.map(
                                    (tc) => ToolCallCard(toolCall: tc),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
          ),
          // 输入区域
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final aiEngine = context.watch<AIEngine>();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _newSession,
            tooltip: '新对话',
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '输入消息...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xLarge),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.medium,
                  vertical: AppSpacing.small + 2,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: AppSpacing.small),
          aiEngine.isGenerating
              ? IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: () => aiEngine.stopGenerating(),
                  color: theme.colorScheme.error,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.errorContainer,
                  ),
                )
              : FilledButton(
                  onPressed: _sendMessage,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(AppSpacing.small + 4),
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(Icons.send_rounded),
                ),
        ],
      ),
    );
  }
}
