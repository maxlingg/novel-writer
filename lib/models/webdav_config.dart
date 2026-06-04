/// WebDAV配置模型
class WebDAVConfig {
  String serverUrl;
  String username;
  String password;
  String remotePath;
  bool autoSync;
  int syncIntervalMinutes;
  bool isEnabled;

  WebDAVConfig({
    this.serverUrl = '',
    this.username = '',
    this.password = '',
    this.remotePath = '/NovelWriter/',
    this.autoSync = false,
    this.syncIntervalMinutes = 30,
    this.isEnabled = false,
  });

  factory WebDAVConfig.fromJson(Map<String, dynamic> json) {
    return WebDAVConfig(
      serverUrl: json['serverUrl'] as String? ?? '',
      username: json['username'] as String? ?? '',
      password: json['password'] as String? ?? '',
      remotePath: json['remotePath'] as String? ?? '/NovelWriter/',
      autoSync: json['autoSync'] as bool? ?? false,
      syncIntervalMinutes: json['syncIntervalMinutes'] as int? ?? 30,
      isEnabled: json['isEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serverUrl': serverUrl,
      'username': username,
      'password': password,
      'remotePath': remotePath,
      'autoSync': autoSync,
      'syncIntervalMinutes': syncIntervalMinutes,
      'isEnabled': isEnabled,
    };
  }

  /// 是否配置完整
  bool get isConfigured {
    return serverUrl.isNotEmpty && username.isNotEmpty && password.isNotEmpty;
  }

  WebDAVConfig copyWith({
    String? serverUrl,
    String? username,
    String? password,
    String? remotePath,
    bool? autoSync,
    int? syncIntervalMinutes,
    bool? isEnabled,
  }) {
    return WebDAVConfig(
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      remotePath: remotePath ?? this.remotePath,
      autoSync: autoSync ?? this.autoSync,
      syncIntervalMinutes: syncIntervalMinutes ?? this.syncIntervalMinutes,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
