import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../models/daily_content.dart';
import '../providers/module_provider.dart';
import '../providers/daily_content_provider.dart';
import '../widgets/daily_card.dart';
import '../widgets/module_grid_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final moduleProvider = context.read<ModuleProvider>();
    final contentProvider = context.read<DailyContentProvider>();

    if (moduleProvider.modules.isEmpty) {
      await moduleProvider.loadModules();
    }

    for (final module in moduleProvider.modules) {
      if (contentProvider.getContent(module.id) == null) {
        contentProvider.loadContent(module);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),

          Consumer<DailyContentProvider>(
            builder: (context, contentProvider, _) {
              return Consumer<ModuleProvider>(
                builder: (context, moduleProvider, _) {
                  if (moduleProvider.modules.isEmpty) {
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  }

                  final featuredModule = moduleProvider.modules.first;
                  final content = contentProvider.getContent(featuredModule.id);
                  final loading = contentProvider.isLoading(featuredModule.id);
                  final generating = contentProvider.isGenerating(featuredModule.id);

                  return SliverToBoxAdapter(
                    child: DailyCard(
                      module: featuredModule,
                      content: content,
                      isLoading: loading,
                      isGenerating: generating,
                      onTap: () => _navigateToDetail(featuredModule.id),
                      onRefresh: () => contentProvider.refreshWithAi(featuredModule),
                      onShare: () => _navigateToPoster(content),
                    ),
                  );
                },
              );
            },
          ),

          SliverToBoxAdapter(
            child: _buildSectionTitle(context, 'More Modules'),
          ),

          Consumer<ModuleProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return SliverFillRemaining(
                  child: _buildLoadingGrid(),
                );
              }

              if (provider.modules.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No modules')),
                );
              }

              final otherModules = provider.modules.skip(1).toList();

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final module = otherModules[index];
                      return ModuleGridItem(
                        module: module,
                        onTap: () => _navigateToDetail(module.id),
                      );
                    },
                    childCount: otherModules.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getDateString(),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'ZhiBanKouDai',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Daily',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Your Personal Expert Knowledge Base',
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  String _getDateString() {
    final now = DateTime.now();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[now.weekday - 1];
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} $weekday';
  }

  void _navigateToDetail(String moduleId) {
    context.push('/module/$moduleId');
  }

  void _navigateToPoster(DailyContent? content) {
    if (content == null) return;
    context.push(RoutePaths.poster, extra: {
      'content': content.content,
      'title': content.title,
      'subtitle': content.subtitle,
      'categoryIcon': content.categoryIcon,
    });
  }
}