import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/l10n/gen/app_localizations.dart';
import 'package:flutter_application_zhiban/xui/pages/experts.dart';
import 'package:flutter_application_zhiban/config/theme.dart';
import 'package:flutter_application_zhiban/xui/utils/module.dart';
import 'package:http/http.dart' as http;

class CollectionsListPage extends StatefulWidget {
  const CollectionsListPage({super.key});

  @override
  State<CollectionsListPage> createState() => _CollectionsListPageState();
}

class _CollectionsListPageState extends State<CollectionsListPage> {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        title: Text(AppLocalizations.of(context)!.assistantList),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchData(isRefresh: true),
        child: ListView.builder(
          controller: _controller,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14, 14, 14, 24 + MediaQuery.paddingOf(context).bottom),
          itemCount: _list.length + 1,
          itemBuilder: (context, index) {
            if (index < _list.length) {
              final item = _list[index];
              return _CollectionRow(collection: item['name'] ?? '');
            }
            return _LoadMoreRow(
              isLoading: isLoading,
              hasMore: hasMore,
              onPressed: _fetchData,
            );
          },
        ),
      ),
    );
  }
}

class _CollectionRow extends StatelessWidget {
  final String collection;

  const _CollectionRow({required this.collection});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final module = findModuleByCollection(collection);
    final name = module?.name ?? collection;
    final icon = module?.icon ?? "📁";
    final slogan = module?.slogan ?? AppLocalizations.of(context)!.viewDataset;
    final colors = module?.colors;
    final accent = colors != null ? AppTheme.fromHex(colors.accent) : colorScheme.primary;
    final textColor = colors != null ? AppTheme.fromHex(colors.text) : colorScheme.onSurface;
    final subTextColor = colors != null ? AppTheme.fromHex(colors.textSecondary) : colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ExpertsPage(collectionName: collection)),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colorScheme.outline, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(fontSize: 17, color: textColor)),
                    const SizedBox(height: 4),
                    Text(slogan, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(fontSize: 13, color: subTextColor)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.secondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadMoreRow extends StatelessWidget {
  final bool isLoading;
  final bool hasMore;
  final VoidCallback onPressed;

  const _LoadMoreRow({required this.isLoading, required this.hasMore, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (isLoading) {
      return const Padding(padding: EdgeInsets.all(18), child: Center(child: CircularProgressIndicator()));
    }
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.all(18),
        child: Center(child: Text(AppLocalizations.of(context)!.noMoreData, style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary))),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(18),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(AppLocalizations.of(context)!.loadingMore),
      ),
    );
  }
}
