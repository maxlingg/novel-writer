import '../utils/constants.dart';

/// AI模型配置
class AIModelConfig {
  String id;
  String name;
  String displayName;
  AIProviderType provider;
  String modelId;         // 模型标识符 (如 "claude-3-sonnet")
  String apiKey;
  String baseUrl;         // 自定义API地址
  int maxTokens;
  double temperature;
  double topP;
  Map<String, dynamic> extraParams;
  bool isEnabled;
  DateTime createdAt;

  AIModelConfig({
    required this.id,
    required this.name,
    required this.displayName,
    required this.provider,
    required this.modelId,
    this.apiKey = '',
    this.baseUrl = '',
    this.maxTokens = 4096,
    this.temperature = 0.7,
    this.topP = 1.0,
    this.extraParams = const {},
    this.isEnabled = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AIModelConfig.fromJson(Map<String, dynamic> json) {
    return AIModelConfig(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      provider: _parseProvider(json['provider'] as String?),
      modelId: json['modelId'] as String? ?? '',
      apiKey: json['apiKey'] as String? ?? '',
      baseUrl: json['baseUrl'] as String? ?? '',
      maxTokens: json['maxTokens'] as int? ?? 4096,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      topP: (json['topP'] as num?)?.toDouble() ?? 1.0,
      extraParams: json['extraParams'] as Map<String, dynamic>? ?? {},
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'provider': provider.name,
      'modelId': modelId,
      'apiKey': apiKey,
      'baseUrl': baseUrl,
      'maxTokens': maxTokens,
      'temperature': temperature,
      'topP': topP,
      'extraParams': extraParams,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 获取API基础URL
  String get effectiveBaseUrl {
    if (baseUrl.isNotEmpty) return baseUrl;
    switch (provider) {
      case AIProviderType.anthropic:
        return 'https://api.anthropic.com';
      case AIProviderType.openai:
        return 'https://api.openai.com';
      case AIProviderType.deepseek:
        return 'https://api.deepseek.com';
      case AIProviderType.glm:
        return 'https://open.bigmodel.cn/api/paas';
      case AIProviderType.kimi:
        return 'https://api.moonshot.cn';
    }
  }

  static AIProviderType _parseProvider(String? provider) {
    switch (provider) {
      case 'anthropic':
        return AIProviderType.anthropic;
      case 'openai':
        return AIProviderType.openai;
      case 'deepseek':
        return AIProviderType.deepseek;
      case 'glm':
        return AIProviderType.glm;
      case 'kimi':
        return AIProviderType.kimi;
      default:
        return AIProviderType.anthropic;
    }
  }

  AIModelConfig copyWith({
    String? name,
    String? displayName,
    AIProviderType? provider,
    String? modelId,
    String? apiKey,
    String? baseUrl,
    int? maxTokens,
    double? temperature,
    double? topP,
    bool? isEnabled,
  }) {
    return AIModelConfig(
      id: id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      provider: provider ?? this.provider,
      modelId: modelId ?? this.modelId,
      apiKey: apiKey ?? this.apiKey,
      baseUrl: baseUrl ?? this.baseUrl,
      maxTokens: maxTokens ?? this.maxTokens,
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      extraParams: extraParams,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt,
    );
  }
}
