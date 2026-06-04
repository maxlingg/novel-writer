import '../models/tool_call.dart';

/// AI模型提供商抽象接口
abstract class AIModelProvider {
  final String apiKey;
  final String baseUrl;

  AIModelProvider({required this.apiKey, required this.baseUrl});

  /// 发送聊天请求
  Future<AIResponse> chat({
    required String modelId,
    required List<Map<String, dynamic>> messages,
    int maxTokens = 4096,
    double temperature = 0.7,
    double topP = 1.0,
  });

  /// 流式聊天
  Stream<String> chatStream({
    required String modelId,
    required List<Map<String, dynamic>> messages,
    int maxTokens = 4096,
    double temperature = 0.7,
    double topP = 1.0,
  });

  /// 验证API Key是否有效
  Future<bool> validateApiKey();

  /// 获取可用模型列表
  Future<List<String>> getAvailableModels();
}

/// AI响应数据
class AIResponse {
  final String content;
  final List<ToolCallInfo>? toolCalls;
  final int promptTokens;
  final int completionTokens;

  AIResponse({
    required this.content,
    this.toolCalls,
    this.promptTokens = 0,
    this.completionTokens = 0,
  });
}

/// 工具调用信息
class ToolCallInfo {
  final String id;
  final String name;
  final Map<String, dynamic> arguments;

  ToolCallInfo({
    required this.id,
    required this.name,
    required this.arguments,
  });
}
