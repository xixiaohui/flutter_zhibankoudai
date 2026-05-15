import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/xui/pages/collections_list.dart';
import 'package:go_router/go_router.dart';
import '../l10n/gen/app_localizations.dart';
import '../pages/home_page.dart';
import '../pages/module_detail_page.dart';
import '../pages/poster_page.dart';
import '../pages/mine_page.dart';
import '../pages/ai_friend_page.dart';
import '../pages/ai_career_page.dart';
import '../pages/ai_career_detail_page.dart';
import '../models/career.dart';
import '../models/daily_content.dart';
import '../xui/pages/home.dart' as xui;

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
        return PosterPage(dailyContent: state.extra as DailyContent);
      },
    ),
    GoRoute(
      path: '/ai-friend',
      name: 'aiFriend',
      builder: (_, _) => const AIFriendPage(),
    ),
    GoRoute(
      path: '/career',
      name: 'career',
      builder: (_, _) => const AICareerPage(),
    ),
    GoRoute(
      path: '/career/:careerId',
      name: 'careerDetail',
      builder: (context, state) {
        final career = state.extra as Career;
        return AICareerDetailPage(career: career);
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

          return NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (i) {
              switch (i) {
                case 0: context.go(RoutePaths.home);
                case 1: context.go(RoutePaths.discover);
                case 2: context.go(RoutePaths.agent);
                case 3: context.go(RoutePaths.mine);
              }
            },
            destinations: [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: AppLocalizations.of(context).bottomNavHome),
              NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: AppLocalizations.of(context).bottomNavDiscover),
              NavigationDestination(icon: Icon(Icons.bolt_outlined), selectedIcon: Icon(Icons.bolt), label: AppLocalizations.of(context).bottomNavAssistant),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: AppLocalizations.of(context).bottomNavMine),
            ],
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