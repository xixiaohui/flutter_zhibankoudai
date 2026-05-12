import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';
import '../models/career.dart';
import '../xui/x_design.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        backgroundColor: AppTheme.pureWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'AI Career',
          style: TextStyle(color: AppTheme.clayBlack, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('加载失败', style: XuiTheme.bodyStd()),
            const SizedBox(height: 8),
            TextButton(onPressed: _loadCareers, child: const Text('重试')),
          ],
        ),
      );
    }

    final careers = _careers!;
    final grouped = <String, List<Career>>{};
    for (final c in careers) {
      grouped.putIfAbsent(c.category, () => []).add(c);
    }

    final categories = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: categories.length,
      itemBuilder: (_, i) => _buildCategorySection(categories[i]),
    );
  }

  Widget _buildCategorySection(MapEntry<String, List<Career>> entry) {
    final cat = entry.value.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
          child: Row(
            children: [
              Text(cat.categoryIcon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                cat.categoryName.isNotEmpty ? cat.categoryName : cat.category,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.clayBlack,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.oatLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                ),
                child: Text(
                  '${entry.value.length}',
                  style: XuiTheme.badge(),
                ),
              ),
            ],
          ),
        ),
        ...entry.value.map((career) => _buildCareerCard(career)),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildCareerCard(Career career) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          context.push('/career/${career.id}', extra: career);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.pureWhite,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppTheme.oatBorder),
            boxShadow: AppTheme.clayShadow,
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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.clayBlack,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      career.vibeZh.isNotEmpty ? career.vibeZh : career.vibe,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.warmCharcoal,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.warmSilver, size: 20),
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
