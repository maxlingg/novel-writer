import 'package:flutter/material.dart';
import '../models/webdav_config.dart';
import '../services/settings_service.dart';
import '../services/webdav_service.dart';
import '../utils/constants.dart';

/// WebDAV设置页面
class WebDAVScreen extends StatefulWidget {
  const WebDAVScreen({super.key});

  @override
  State<WebDAVScreen> createState() => _WebDAVScreenState();
}

class _WebDAVScreenState extends State<WebDAVScreen> {
  final _serverUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _remotePathController = TextEditingController();
  bool _autoSync = false;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _remotePathController.dispose();
    super.dispose();
  }

  void _loadConfig() {
    final settings = context.read<SettingsService>();
    final config = settings.webdavConfig;

    _serverUrlController.text = config.serverUrl;
    _usernameController.text = config.username;
    _passwordController.text = config.password;
    _remotePathController.text = config.remotePath;
    _autoSync = config.autoSync;
  }

  Future<void> _testConnection() async {
    setState(() => _isTesting = true);

    final config = WebDAVConfig(
      serverUrl: _serverUrlController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      remotePath: _remotePathController.text,
      autoSync: _autoSync,
    );

    final webdavService = context.read<WebDAVService>();
    final success = await webdavService.testConnection(config);

    setState(() => _isTesting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '连接成功' : '连接失败'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _saveConfig() async {
    final config = WebDAVConfig(
      serverUrl: _serverUrlController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      remotePath: _remotePathController.text,
      autoSync: _autoSync,
      isEnabled: true,
    );

    await context.read<SettingsService>().updateWebDAVConfig(config);
    context.read<WebDAVService>().updateConfig(config);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('配置已保存')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebDAV 同步')),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          const Text(
            '配置WebDAV服务器以同步你的小说项目数据。',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _serverUrlController,
            decoration: const InputDecoration(
              labelText: '服务器地址',
              hintText: 'https://dav.example.com',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.dns),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: '用户名',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: '密码',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _remotePathController,
            decoration: const InputDecoration(
              labelText: '远程路径',
              hintText: '/NovelWriter/',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.folder),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('自动同步'),
            subtitle: const Text('定期自动同步项目数据'),
            value: _autoSync,
            onChanged: (value) => setState(() => _autoSync = value),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isTesting ? null : _testConnection,
                  child: _isTesting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('测试连接'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _saveConfig,
                  child: const Text('保存'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
