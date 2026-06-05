import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'utils/constants.dart';
import 'services/settings_service.dart';
import 'screens/home_screen.dart';
import 'screens/project_screen.dart';
import 'screens/editor_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/webdav_screen.dart';
import 'screens/skill_marketplace_screen.dart';
import 'screens/memo_screen.dart';
import 'screens/search_screen.dart';
import 'screens/asset_library_screen.dart';
import 'screens/distillation_screen.dart';

class NovelWriterApp extends StatelessWidget {
  const NovelWriterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // 主题配置
      theme: _buildLightTheme(settings),
      darkTheme: _buildDarkTheme(settings),
      themeMode: settings.themeMode,

      // 路由配置
      initialRoute: AppRoutes.home,
      onGenerateRoute: _generateRoute,

      // 本地化
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
    );
  }

  /// 浅色主题
  ThemeData _buildLightTheme(SettingsService settings) {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorSchemeSeed: settings.accentColor,
      fontFamily: settings.fontFamily,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
    );
  }

  /// 深色主题
  ThemeData _buildDarkTheme(SettingsService settings) {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorSchemeSeed: settings.accentColor,
      fontFamily: settings.fontFamily,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
    );
  }

  /// 路由生成
  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      case AppRoutes.project:
        final projectId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ProjectScreen(projectId: projectId),
        );
      case AppRoutes.editor:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EditorScreen(
            projectId: args?['projectId'] ?? '',
            chapterId: args?['chapterId'] ?? '',
          ),
        );
      case AppRoutes.aiChat:
        final projectId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => AIChatScreen(projectId: projectId),
        );
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );
      case AppRoutes.webdav:
        return MaterialPageRoute(
          builder: (_) => const WebDAVScreen(),
        );
      case AppRoutes.skillMarketplace:
        return MaterialPageRoute(
          builder: (_) => const SkillMarketplaceScreen(),
        );
      case AppRoutes.memo:
        final projectId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => MemoScreen(projectId: projectId),
        );
      case AppRoutes.search:
        final projectId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => SearchScreen(projectId: projectId),
        );
      case AppRoutes.assetLibrary:
        final projectId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => AssetLibraryScreen(projectId: projectId),
        );
      case AppRoutes.distillation:
        final projectId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => DistillationScreen(projectId: projectId),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('页面未找到')),
          ),
        );
    }
  }
}
