# Novel Writer

一款 AI 驱动的小说创作工具，基于 Flutter 开发，仅支持 Android 平台。

## 功能特性

- **AI 辅助写作** - 支持 Claude、GPT、DeepSeek、GLM、Kimi 等多种 AI 模型
- **智能体体系** - Agent + Tool + Skill 三层架构，AI 可操作项目文件
- **技能系统** - 插件化技能架构，支持创建/分享/安装技能
- **项目管理** - 项目 > 卷 > 章节层级管理
- **富文本编辑器** - HTML 格式编辑，自动保存
- **DOCX 导入导出** - 完整的 Word 文档支持
- **WebDAV 云同步** - 支持与 NAS/云存储同步
- **搜索功能** - 本地文件搜索 + 网络搜索
- **主题系统** - 深色/浅色/跟随系统
- **备忘录** - 创作灵感记录

## 技术栈

- **框架**: Flutter 3.x (Dart)
- **状态管理**: Provider
- **平台**: Android (arm64-v8a)
- **数据存储**: 本地文件系统 + SharedPreferences

## 项目结构

```
lib/
├── main.dart              # 应用入口
├── app.dart               # 根组件（路由/主题）
├── models/                # 数据模型
├── services/              # 业务逻辑服务
│   ├── providers/         # AI 模型提供商
│   └── tools/             # Agent 工具
├── screens/               # 页面 UI
├── widgets/               # 自定义组件
└── utils/                 # 工具类
```

## 快速开始

```bash
# 获取依赖
flutter pub get

# 运行
flutter run

# 构建 APK
flutter build apk --release
```

## 配置 AI 模型

在设置页面配置对应模型的 API Key：
- Anthropic Claude: [console.anthropic.com](https://console.anthropic.com)
- OpenAI GPT: [platform.openai.com](https://platform.openai.com)
- DeepSeek: [platform.deepseek.com](https://platform.deepseek.com)
- 智谱 GLM: [open.bigmodel.cn](https://open.bigmodel.cn)
- Kimi: [platform.moonshot.cn](https://platform.moonshot.cn)

## 许可证

MIT License
