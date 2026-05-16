import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/l10n/gen/app_localizations.dart';
import 'package:flutter_application_zhiban/xui/pages/experts.dart';
import 'package:flutter_application_zhiban/config/theme.dart';
import 'package:flutter_application_zhiban/xui/utils/module.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;

class CollectionsGridPage extends StatefulWidget {
  const CollectionsGridPage({super.key});

  @override
  State<CollectionsGridPage> createState() => _CollectionsGridPageState();
}

class _CollectionsGridPageState extends State<CollectionsGridPage> {
  final List<dynamic> _list = [];
  final ScrollController _controller = ScrollController();

  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _controller.addListener(() {
      if (!mounted || isLoading || !hasMore) return;
      if (_controller.position.pixels >= _controller.position.maxScrollExtent - 240) {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData({bool isRefresh = false}) async {
    if (isLoading) return;

    setState(() => isLoading = true);
    if (isRefresh) {
      page = 1;
      _list.clear();
      hasMore = true;
    }

    try {
      final res = await http.get(
        Uri.parse('https://www.xclaw.living/api/hunyuan/meta?page=$page&limit=12'),
      );
      if (!mounted) return;

      final jsonData = json.decode(res.body);
      final List data = jsonData['data'] ?? [];
      setState(() {
        _list.addAll(data);
        hasMore = jsonData['hasMore'] ?? false;
        if (hasMore) page++;
      });
    } catch (e) {
      debugPrint("Fetch collections failed: $e");
    }

    if (mounted) setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _columnsForWidth(double width) {
    if (width >= 900) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        title: Text(AppLocalizations.of(context)!.assistantSquare),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchData(isRefresh: true),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return MasonryGridView.count(
              controller: _controller,
              physics: const AlwaysScrollableScrollPhysics(),
              crossAxisCount: _columnsForWidth(constraints.maxWidth),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              padding: EdgeInsets.fromLTRB(14, 14, 14, 24 + MediaQuery.paddingOf(context).bottom),
              itemCount: _list.length + 1,
              itemBuilder: (context, index) {
                if (index < _list.length) {
                  final item = _list[index];
                  return _CollectionTile(collection: item['name'] ?? '');
                }
                return _LoadMoreTile(
                  isLoading: isLoading,
                  hasMore: hasMore,
                  onPressed: _fetchData,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  final String collection;

  const _CollectionTile({required this.collection});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final module = findModuleByCollection(collection);
    final name = module?.name ?? collection;
    final icon = module?.icon ?? "📁";
    final slogan = module?.slogan ?? AppLocalizations.of(context)!.viewDataset;
    final colors = module?.colors;
    final accent = colors != null ? AppTheme.fromHex(colors.accent) : colorScheme.primary;
    final start = colors != null
        ? AppTheme.fromHex(colors.gradientStart)
        : (isDark ? colorScheme.surface : colorScheme.surface);
    final end = colors != null
        ? AppTheme.fromHex(colors.gradientEnd)
        : (isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFeff1f3));
    final textColor = colors != null ? AppTheme.fromHex(colors.text) : colorScheme.onSurface;
    final subTextColor = colors != null ? AppTheme.fromHex(colors.textSecondary) : colorScheme.secondary;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ExpertsPage(collectionName: collection)),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [start, end], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colorScheme.outline, width: 0.5),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 23))),
            ),
            const SizedBox(height: 12),
            Text(name, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall?.copyWith(fontSize: 17, color: textColor)),
            const SizedBox(height: 8),
            Text(slogan, maxLines: 3, overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(fontSize: 13, color: subTextColor, height: 1.45)),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.chevron_right, size: 20, color: colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreTile extends StatelessWidget {
  final bool isLoading;
  final bool hasMore;
  final VoidCallback onPressed;

  const _LoadMoreTile({required this.isLoading, required this.hasMore, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (isLoading) return const Center(child: Padding(padding: EdgeInsets.all(18), child: CircularProgressIndicator()));
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text(AppLocalizations.of(context)!.noMoreData, style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary))),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(AppLocalizations.of(context)!.loadingMore),
      ),
    );
  }
}
