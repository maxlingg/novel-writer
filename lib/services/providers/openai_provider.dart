import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ai_model_provider.dart';

/// OpenAI (GPT) 提供商
class OpenAIProvider extends AIModelProvider {
  OpenAIProvider({required super.apiKey, required super.baseUrl});

  @override
  Future<AIResponse> chat({
    required String modelId,
    required List<Map<String, dynamic>> messages,
    int maxTokens = 4096,
    double temperature = 0.7,
    double topP = 1.0,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': modelId,
        'max_tokens': maxTokens,
        'temperature': temperature,
        'top_p': topP,
        'messages': messages,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('OpenAI API错误: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choice = (data['choices'] as List<dynamic>).first as Map<String, dynamic>;
    final message = choice['message'] as Map<String, dynamic>;

    // 解析工具调用
    List<ToolCallInfo>? toolCalls;
    if (message['tool_calls'] != null) {
      toolCalls = (message['tool_calls'] as List<dynamic>).map((tc) {
        final toolCall = tc as Map<String, dynamic>;
        return ToolCallInfo(
          id: toolCall['id'] as String,
          name: (toolCall['function'] as Map<String, dynamic>)['name'] as String,
          arguments: jsonDecode(
            (toolCall['function'] as Map<String, dynamic>)['arguments'] as String,
          ) as Map<String, dynamic>,
        );
      }).toList();
    }

    return AIResponse(
      content: message['content'] as String? ?? '',
      toolCalls: toolCalls,
      promptTokens: data['usage']?['prompt_tokens'] ?? 0,
      completionTokens: data['usage']?['completion_tokens'] ?? 0,
    );
  }

  @override
  Stream<String> chatStream({
    required String modelId,
    required List<Map<String, dynamic>> messages,
    int maxTokens = 4096,
    double temperature = 0.7,
    double topP = 1.0,
  }) async* {
    // TODO: 实现SSE流式响应
    final response = await chat(
      modelId: modelId,
      messages: messages,
      maxTokens: maxTokens,
      temperature: temperature,
      topP: topP,
    );
    yield response.content;
  }

  @override
  Future<bool> validateApiKey() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/models'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<String>> getAvailableModels() async {
    return ['gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo'];
  }
}
