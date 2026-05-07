import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/xui/pages/collections_list.dart';
import 'package:go_router/go_router.dart';
import '../pages/home_page.dart';
import '../pages/module_detail_page.dart';
import '../pages/poster_page.dart';
import '../pages/mine_page.dart';
import '../xui/pages/home.dart' as xui;
import 'theme.dart';

class RoutePaths {
  RoutePaths._();
  static const String home = '/';
  static const String discover = '/discover';
  static const String mine = '/mine';
  static const String moduleDetail = '/module/:moduleId';
  static const String poster = '/poster';
  static const String agent = '/agent';
}

class RouteNames {
  RouteNames._();
  static const String home = 'home';
  static const String discover = 'discover';
  static const String mine = 'mine';
  static const String moduleDetail = 'moduleDetail';
  static const String poster = 'poster';
  static const String agent = 'agent';
}

final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.home,
  debugLogDiagnostics: false,
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: RoutePaths.home,
          name: RouteNames.home,
          builder: (_, _) => const HomePage(),
        ),
        GoRoute(
          path: RoutePaths.discover,
          name: RouteNames.discover,
          builder: (_, _) => const _DiscoverPage(),
        ),
        GoRoute(
          path: RoutePaths.mine,
          name: RouteNames.mine,
          builder: (_, _) => const MinePage(),
        ),
        GoRoute(
          path: RoutePaths.agent,
          name: RouteNames.agent,
          builder: (_, _) => const xui.HomePage(),
        ),
        
      ],
    ),
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

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Builder(
        builder: (context) {
          final path = GoRouterState.of(context).uri.path;
          int index = 0;
          if (path.startsWith(RoutePaths.discover)) index = 1;
          if (path.startsWith(RoutePaths.agent)) index = 2;
          if (path.startsWith(RoutePaths.mine)) index = 3;

          return Container(
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              border: const Border(top: BorderSide(color: AppTheme.oatBorder)),
              boxShadow: AppTheme.clayShadow,
            ),
            child: BottomNavigationBar(
              currentIndex: index,
              onTap: (i) {
                switch (i) {
                  case 0: context.go(RoutePaths.home);
                  case 1: context.go(RoutePaths.discover);
                  case 2: context.go(RoutePaths.agent);
                  case 3: context.go(RoutePaths.mine);
                }
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: '首页'),
                BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: '发现'),
                BottomNavigationBarItem(icon: Icon(Icons.assignment_ind_outlined), activeIcon: Icon(Icons.assignment_ind), label: '助理'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '我的'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DiscoverPage extends StatelessWidget {
  const _DiscoverPage();
  @override
  Widget build(BuildContext context) {
    return const CollectionsListPage();
  }
}