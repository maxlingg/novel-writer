import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ai_model_provider.dart';

/// Anthropic (Claude) 提供商
class AnthropicProvider extends AIModelProvider {
  AnthropicProvider({required super.apiKey, required super.baseUrl});

  @override
  Future<AIResponse> chat({
    required String modelId,
    required List<Map<String, dynamic>> messages,
    int maxTokens = 4096,
    double temperature = 0.7,
    double topP = 1.0,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/messages'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': modelId,
        'max_tokens': maxTokens,
        'temperature': temperature,
        'top_p': topP,
        'messages': messages
            .where((m) => m['role'] != 'system')
            .toList(),
        'system': _extractSystemPrompt(messages),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Anthropic API错误: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = (data['content'] as List<dynamic>)
        .map((e) => (e as Map<String, dynamic>)['text'] as String)
        .join();

    return AIResponse(
      content: content,
      promptTokens: data['usage']?['input_tokens'] ?? 0,
      completionTokens: data['usage']?['output_tokens'] ?? 0,
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
        headers: {'x-api-key': apiKey, 'anthropic-version': '2023-06-01'},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<String>> getAvailableModels() async {
    return ['claude-sonnet-4-20250514', 'claude-opus-4-20250514', 'claude-haiku-3-5-20241022'];
  }

  String _extractSystemPrompt(List<Map<String, dynamic>> messages) {
    final system = messages.where((m) => m['role'] == 'system');
    return system.map((m) => m['content'] as String).join('\n');
  }
}
