import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ai_model_provider.dart';

/// Kimi (Moonshot) 提供商
class KimiProvider extends AIModelProvider {
  KimiProvider({required super.apiKey, required super.baseUrl});

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
      throw Exception('Kimi API错误: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choice = (data['choices'] as List<dynamic>).first as Map<String, dynamic>;
    final message = choice['message'] as Map<String, dynamic>;

    return AIResponse(
      content: message['content'] as String? ?? '',
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
    return ['moonshot-v1-128k', 'moonshot-v1-32k', 'moonshot-v1-8k'];
  }
}
