import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/home_page.dart';
import '../pages/module_detail_page.dart';
import '../pages/poster_page.dart';
import '../pages/mine_page.dart';

/// 路由路径常量
class RoutePaths {
  RoutePaths._();
  static const String home = '/';
  static const String discover = '/discover';
  static const String mine = '/mine';
  static const String moduleDetail = '/module/:moduleId';
  static const String poster = '/poster';
}

/// 路由名称常量（用于导航）
class RouteNames {
  RouteNames._();
  static const String home = 'home';
  static const String discover = 'discover';
  static const String mine = 'mine';
  static const String moduleDetail = 'moduleDetail';
  static const String poster = 'poster';
}

/// 全局路由配置
final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.home,
  debugLogDiagnostics: true,
  routes: [
    // 底部导航 Shell 路由
    ShellRoute(
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: RoutePaths.home,
          name: RouteNames.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: RoutePaths.discover,
          name: RouteNames.discover,
          builder: (context, state) => const _DiscoverPage(),
        ),
        GoRoute(
          path: RoutePaths.mine,
          name: RouteNames.mine,
          builder: (context, state) => const MinePage(),
        ),
      ],
    ),
    // 独立页面（不在底部导航中）
    GoRoute(
      path: '/module/:moduleId',
      name: RouteNames.moduleDetail,
      builder: (context, state) {
        final moduleId = state.pathParameters['moduleId'] ?? '';
        return ModuleDetailPage(moduleId: moduleId);
      },
    ),
    GoRoute(
      path: RoutePaths.poster,
      name: RouteNames.poster,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return PosterPage(
          content: extra['content'] ?? '',
          title: extra['title'] ?? '',
          subtitle: extra['subtitle'] ?? '',
          categoryIcon: extra['categoryIcon'] ?? '',
        );
      },
    ),
  ],
);

/// 主页面 Shell（包含底部导航栏）
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Builder(
        builder: (context) {
          final String currentPath = GoRouterState.of(context).uri.path;
          int currentIndex = 0;
          if (currentPath.startsWith(RoutePaths.discover)) {
            currentIndex = 1;
          } else if (currentPath.startsWith(RoutePaths.mine)) {
            currentIndex = 2;
          }

          return BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go(RoutePaths.home);
                  break;
                case 1:
                  context.go(RoutePaths.discover);
                  break;
                case 2:
                  context.go(RoutePaths.mine);
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: '首页',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: '发现',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: '我的',
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 发现页占位
class _DiscoverPage extends StatelessWidget {
  const _DiscoverPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('发现')),
      body: const Center(
        child: Text('发现页 - 开发中', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}