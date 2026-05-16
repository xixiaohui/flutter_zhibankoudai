import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/career.dart';

class AICareerPage extends StatefulWidget {
  const AICareerPage({super.key});

  @override
  State<AICareerPage> createState() => _AICareerPageState();
}

class _AICareerPageState extends State<AICareerPage> {
  List<Career>? _careers;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCareers();
  }

  Future<void> _loadCareers() async {
    try {
      final careers = await Career.loadAll();
      if (!mounted) return;
      setState(() {
        _careers = careers;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'AI Career',
          style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _buildBody(colorScheme, textTheme),
    );
  }

  Widget _buildBody(ColorScheme colorScheme, TextTheme textTheme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.loadFailed, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            TextButton(onPressed: _loadCareers, child: Text(AppLocalizations.of(context)!.retry)),
          ],
        ),
      );
    }

    final careers = _careers!.where((c) => c.name.isNotEmpty).toList();
    final grouped = <String, List<Career>>{};
    for (final c in careers) {
      final catKey = c.category.isNotEmpty ? c.category : AppLocalizations.of(context)!.otherCategory;
      grouped.putIfAbsent(catKey, () => []).add(c);
    }

    final categories = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: categories.length,
      itemBuilder: (_, i) => _buildCategorySection(categories[i], colorScheme, textTheme),
    );
  }

  Widget _buildCategorySection(MapEntry<String, List<Career>> entry, ColorScheme colorScheme, TextTheme textTheme) {
    final cat = entry.value.first;
    final icon = cat.categoryIcon.isNotEmpty ? cat.categoryIcon : '📋';
    final name = cat.categoryName.isNotEmpty
        ? cat.categoryName
        : (cat.category.isNotEmpty ? cat.category : AppLocalizations.of(context)!.otherCategory);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                name,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  '${entry.value.length}',
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.secondary),
                ),
              ),
            ],
          ),
        ),
        ...entry.value.map((career) => _buildCareerCard(career, colorScheme, textTheme)),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildCareerCard(Career career, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          context.push('/career/${career.id}', extra: career);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.outline, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _parseColor(career.color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(career.emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      career.nameZh.isNotEmpty ? career.nameZh : career.name,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      career.vibeZh.isNotEmpty ? career.vibeZh : career.vibe,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.secondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String color) {
    if (color.startsWith('#')) {
      final hex = color.substring(1);
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      return Colors.grey;
    }
    // named colors
    switch (color.toLowerCase()) {
      case 'purple': return Colors.purple;
      case 'cyan': return Colors.cyan;
      case 'blue': return Colors.blue;
      case 'red': return Colors.red;
      case 'green': return Colors.green;
      case 'orange': return Colors.orange;
      case 'pink': return Colors.pink;
      case 'teal': return Colors.teal;
      case 'amber': return Colors.amber;
      case 'indigo': return Colors.indigo;
      default: return Colors.grey;
    }
  }
}
