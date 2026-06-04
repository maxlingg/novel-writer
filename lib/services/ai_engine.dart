import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../models/ai_model_config.dart';
import '../models/tool_call.dart';
import 'ai_model_provider.dart';
import 'tool_registry.dart';
import '../utils/constants.dart';

/// AI聊天引擎
class AIEngine extends ChangeNotifier {
  AIModelProvider? _currentProvider;
  ToolRegistry? _toolRegistry;
  bool _isGenerating = false;
  String? _error;
  StreamSubscription? _responseSubscription;

  bool get isGenerating => _isGenerating;
  String? get error => _error;

  /// 设置工具注册表
  void setToolRegistry(ToolRegistry registry) {
    _toolRegistry = registry;
  }

  /// 发送消息
  Future<List<ChatMessage>> sendMessage({
    required ChatSession session,
    required String userMessage,
    required AIModelConfig modelConfig,
    List<ChatMessage> history = const [],
    String? skillPrompt,
  }) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      // 构建消息列表
      final messages = <Map<String, dynamic>>[];

      // 系统提示
      final systemContent = StringBuffer();
      if (session.systemPrompt.isNotEmpty) {
        systemContent.write(session.systemPrompt);
      }
      if (skillPrompt != null && skillPrompt.isNotEmpty) {
        if (systemContent.isNotEmpty) systemContent.write('\n\n');
        systemContent.write(skillPrompt);
      }
      if (systemContent.isNotEmpty) {
        messages.add({'role': 'system', 'content': systemContent.toString()});
      }

      // 历史消息
      for (final msg in history) {
        messages.add({
          'role': msg.role.name,
          'content': msg.content,
        });
      }

      // 用户消息
      messages.add({'role': 'user', 'content': userMessage});

      // 调用AI
      final provider = _getProvider(modelConfig);
      final response = await provider.chat(
        modelId: modelConfig.modelId,
        messages: messages,
        maxTokens: modelConfig.maxTokens,
        temperature: modelConfig.temperature,
        topP: modelConfig.topP,
      );

      // 处理工具调用
      final assistantMessage = ChatMessage(
        sessionId: session.id,
        role: MessageRole.assistant,
        content: response.content,
        toolCalls: response.toolCalls?.map((tc) => ToolCall(
          id: tc.id,
          name: tc.name,
          arguments: tc.arguments,
          status: ToolCallStatus.completed,
        )).toList(),
      );

      // 执行工具调用
      if (response.toolCalls != null && response.toolCalls!.isNotEmpty) {
        for (final toolCall in response.toolCalls!) {
          if (_toolRegistry != null) {
            try {
              final result = await _toolRegistry!.executeTool(
                name: toolCall.name,
                arguments: toolCall.arguments,
              );
              // 将工具结果添加到消息列表
              messages.add({
                'role': 'tool',
                'tool_call_id': toolCall.id,
                'content': result,
              });
            } catch (e) {
              debugPrint('工具调用失败: $e');
            }
          }
        }

        // 如果有工具调用，再次调用AI获取最终回复
        final finalResponse = await provider.chat(
          modelId: modelConfig.modelId,
          messages: messages,
          maxTokens: modelConfig.maxTokens,
          temperature: modelConfig.temperature,
          topP: modelConfig.topP,
        );

        return [
          ChatMessage(
            sessionId: session.id,
            role: MessageRole.user,
            content: userMessage,
          ),
          assistantMessage,
          ChatMessage(
            sessionId: session.id,
            role: MessageRole.assistant,
            content: finalResponse.content,
          ),
        ];
      }

      return [
        ChatMessage(
          sessionId: session.id,
          role: MessageRole.user,
          content: userMessage,
        ),
        assistantMessage,
      ];
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [
        ChatMessage(
          sessionId: session.id,
          role: MessageRole.user,
          content: userMessage,
        ),
        ChatMessage(
          sessionId: session.id,
          role: MessageRole.assistant,
          content: '抱歉，发生了错误：$e',
          isError: true,
        ),
      ];
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  /// 停止生成
  void stopGenerating() {
    _responseSubscription?.cancel();
    _isGenerating = false;
    notifyListeners();
  }

  /// 获取AI提供商
  AIModelProvider _getProvider(AIModelConfig config) {
    switch (config.provider) {
      case AIProviderType.anthropic:
        return AnthropicProvider(apiKey: config.apiKey, baseUrl: config.effectiveBaseUrl);
      case AIProviderType.openai:
        return OpenAIProvider(apiKey: config.apiKey, baseUrl: config.effectiveBaseUrl);
      case AIProviderType.deepseek:
        return DeepSeekProvider(apiKey: config.apiKey, baseUrl: config.effectiveBaseUrl);
      case AIProviderType.glm:
        return GLMProvider(apiKey: config.apiKey, baseUrl: config.effectiveBaseUrl);
      case AIProviderType.kimi:
        return KimiProvider(apiKey: config.apiKey, baseUrl: config.effectiveBaseUrl);
    }
  }
}
