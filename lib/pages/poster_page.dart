import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'dart:io';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../config/theme.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/daily_content.dart';
import '../models/field_metadata.dart';

class PosterPage extends StatefulWidget {
  final DailyContent dailyContent;

  const PosterPage({super.key, required this.dailyContent});

  @override
  State<PosterPage> createState() => _PosterPageState();
}

class _PosterPageState extends State<PosterPage> {
  static const double _posterWidth = 1080.0;
  static const double _posterPadding = 48.0;
  static const double _capturePixelRatio = 1.0;
  static const int _maxCharsPerPage = 500;

  static bool _isHan(int codeUnit) {
    return (codeUnit >= 0x4e00 && codeUnit <= 0x9fff) ||
        (codeUnit >= 0x3400 && codeUnit <= 0x4dbf);
  }

  static final _posterMarkdownStyle = MarkdownStyleSheet(
  /// 正文
  p: TextStyle(
    color: AppTheme.pureWhite.withValues(alpha: 0.96),
    fontSize: 52,
    fontWeight: FontWeight.w400,
    height: 2.15,
    letterSpacing: 0.8,
    fontFamily: 'NotoSerifSC',
  ),

  /// 一级标题
  h1: TextStyle(
    color: AppTheme.pureWhite,
    fontSize: 76,
    fontWeight: FontWeight.w700,
    height: 1.45,
    letterSpacing: 1.2,
    fontFamily: 'NotoSerifSC',
  ),

  /// 二级标题
  h2: TextStyle(
    color: AppTheme.pureWhite.withValues(alpha: 0.98),
    fontSize: 66,
    fontWeight: FontWeight.w600,
    height: 1.55,
    letterSpacing: 1,
    fontFamily: 'NotoSerifSC',
  ),

  /// 三级标题
  h3: TextStyle(
    color: AppTheme.pureWhite.withValues(alpha: 0.95),
    fontSize: 58,
    fontWeight: FontWeight.w600,
    height: 1.65,
    letterSpacing: 0.8,
    fontFamily: 'NotoSerifSC',
  ),

  /// 加粗
  strong: TextStyle(
    color: AppTheme.pureWhite,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    fontFamily: 'NotoSerifSC',
  ),

  /// 引用（手杖感核心）
  blockquote: TextStyle(
    color: AppTheme.ube200,
    fontSize: 50,
    fontWeight: FontWeight.w400,
    height: 2.2,
    letterSpacing: 1,
    fontStyle: FontStyle.italic,
    fontFamily: 'NotoSerifSC',
  ),

  blockquoteDecoration: BoxDecoration(
    color: AppTheme.pureWhite.withValues(alpha: 0.04),
    border: Border(
      left: BorderSide(
        color: AppTheme.ube300,
        width: 6,
      ),
    ),
    borderRadius: BorderRadius.circular(18),
  ),

  blockquotePadding: const EdgeInsets.symmetric(
    horizontal: 28,
    vertical: 18,
  ),

  /// 列表
  listBullet: TextStyle(
    color: AppTheme.ube100,
    fontSize: 52,
    height: 2.1,
    fontWeight: FontWeight.w500,
    fontFamily: 'NotoSerifSC',
  ),

  /// 行内代码
  code: TextStyle(
    color: AppTheme.ube100,
    fontSize: 46,
    height: 1.8,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    fontFamily: 'JetBrainsMono',
  ),

  /// 代码块
  codeblockDecoration: BoxDecoration(
    color: AppTheme.pureWhite.withValues(alpha: 0.06),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: AppTheme.pureWhite.withValues(alpha: 0.08),
    ),
  ),

  codeblockPadding: const EdgeInsets.all(24),

  /// 分割线
  horizontalRuleDecoration: BoxDecoration(
    border: Border(
      top: BorderSide(
        color: AppTheme.pureWhite.withValues(alpha: 0.12),
        width: 1.5,
      ),
    ),
  ),
);

  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _posterKeys = [];
  List<ScreenshotController> _controllers = [];
  List<String> _contentChunks = [];
  bool _isProcessing = false;

  DailyContent? _lastDailyContent;

  @override
  void initState() {
    super.initState();
    _recalculatePages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recalculatePages();
  }

  @override
  void didUpdateWidget(PosterPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dailyContent != widget.dailyContent) {
      _recalculatePages();
    }
  }

  void _recalculatePages() {
    if (_lastDailyContent == widget.dailyContent && _controllers.isNotEmpty) {
      return;
    }
    _lastDailyContent = widget.dailyContent;

    final newChunks = _splitContent(widget.dailyContent.content);

    setState(() {
      _contentChunks = newChunks;
      _controllers = List.generate(
        newChunks.length,
        (_) => ScreenshotController(),
      );
      _posterKeys
        ..clear()
        ..addAll(List.generate(newChunks.length, (_) => GlobalKey()));
    });
  }

  List<String> _splitContent(String text) {
    int totalHan = 0;
    for (int i = 0; i < text.length; i++) {
      if (_isHan(text.codeUnitAt(i))) totalHan++;
    }
    if (totalHan <= _maxCharsPerPage) return [text];

    final chunks = <String>[];
    int start = 0;
    while (start < text.length) {
      int hanCount = 0;
      int end = start;
      while (end < text.length && hanCount < _maxCharsPerPage) {
        if (_isHan(text.codeUnitAt(end))) hanCount++;
        end++;
      }

      if (end >= text.length) {
        chunks.add(text.substring(start));
        break;
      }

      int breakAt = end;
      for (final char in ['\n', '。', '！', '？', '?', '!', '…', '；']) {
        final lastBreak = text.lastIndexOf(char, end);
        if (lastBreak > start && end - lastBreak < 80) {
          breakAt = lastBreak + 1;
          break;
        }
      }
      chunks.add(text.substring(start, breakAt));
      start = breakAt;
    }
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text(AppLocalizations.of(context)!.generatePoster),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isProcessing ? null : _sharePoster,
            tooltip: AppLocalizations.of(context)!.sharePoster,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  for (int i = 0; i < _contentChunks.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    Padding(
                      key: _posterKeys[i],
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: screenWidth - 48,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.topCenter,
                          child: Screenshot(
                            controller: _controllers[i],
                            child: _buildPageCard(i),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Row(
              children: [
                Expanded(
                  child: _clayBtn(
                    Icons.download,
                    _isProcessing ? AppLocalizations.of(context)!.processing : AppLocalizations.of(context)!.saveToAlbum,
                    _isProcessing ? null : _savePoster,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _clayBtn(
                    Icons.share,
                    AppLocalizations.of(context)!.share,
                    _isProcessing ? null : _sharePoster,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageCard(int pageIndex) {
    final isFirstPage = pageIndex == 0;
    final dc = widget.dailyContent;
    return Container(
      width: _posterWidth,
      padding: const EdgeInsets.all(_posterPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.ube800, AppTheme.ube900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(60),
        border: Border.all(color: AppTheme.oatBorder, width: 2),
        boxShadow: AppTheme.clayShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(dc.categoryIcon, style: const TextStyle(fontSize: 76)),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.posterBranding,
                style: const TextStyle(
                  color: AppTheme.ube300,
                  fontSize: 76,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          MarkdownBody(
            data: _contentChunks[pageIndex],
            styleSheet: _posterMarkdownStyle,
          ),
          if (isFirstPage && dc.title.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              '— ${dc.title}',
              style: TextStyle(
                color: AppTheme.pureWhite.withValues(alpha: 0.8),
                fontSize: 24,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (isFirstPage && dc.subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              dc.subtitle,
              style: TextStyle(
                color: AppTheme.pureWhite.withValues(alpha: 0.6),
                fontSize: 20,
              ),
            ),
          ],
          if (isFirstPage) _buildPosterMetadata(dc),
          const SizedBox(height: 56),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              AppLocalizations.of(context)!.posterFooter,
              style: TextStyle(
                color: AppTheme.pureWhite.withValues(alpha: 0.5),
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterMetadata(DailyContent dc) {
    final rows = <Widget>[];
    dc.extra.forEach((key, value) {
      if (FieldMetadata.skip(key)) return;
      final str = value?.toString() ?? '';
      if (str.isEmpty) return;

      final icon = FieldMetadata.icon(key);
      final label = FieldMetadata.label(key);

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 24,
                color: AppTheme.pureWhite.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 10),
              Text(
                '$label：',
                style: TextStyle(
                  color: AppTheme.pureWhite.withValues(alpha: 0.5),
                  fontSize: 22,
                ),
              ),
              Expanded(
                child: Text(
                  str,
                  style: TextStyle(
                    color: AppTheme.pureWhite.withValues(alpha: 0.8),
                    fontSize: 22,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.pureWhite.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        ),
      ),
    );
  }

  Widget _clayBtn(IconData icon, String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.oatBorder),
          boxShadow: AppTheme.clayShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppTheme.clayBlack),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.clayBlack,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _requestPermission() async {
    if (Platform.isIOS) {
      return await Permission.photosAddOnly.request().isGranted ||
          await Permission.photos.request().isGranted;
    }
    if (await Permission.storage.request().isGranted) return true;
    if (await Permission.photos.request().isGranted) return true;
    return true;
  }

  Future<void> _waitForRender() async {
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 80));
  }

  Future<void> _savePoster() async {
    final messenger = ScaffoldMessenger.of(context);
    final controllers = _controllers;

    setState(() => _isProcessing = true);
    try {
      final ok = await _requestPermission();
      if (!ok) {
        if (mounted) {
          messenger.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.savePermissionRequired)));
        }
        setState(() => _isProcessing = false);
        return;
      }

      await _waitForRender();

      final total = controllers.length;
      for (int i = 0; i < total; i++) {
        if (mounted && total > 1) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.savingImages(i + 1, total)),
              duration: const Duration(seconds: 1),
            ),
          );
        }

        final keyCtx = _posterKeys[i].currentContext;
        if (keyCtx != null) {
          // ignore: use_build_context_synchronously
          await Scrollable.ensureVisible(keyCtx,
              alignment: 0.0, duration: Duration.zero);
        }
        if (!mounted) return;
        await _waitForRender();

        final image = await controllers[i].capture(
          pixelRatio: _capturePixelRatio,
        );
        if (image != null) {
          final dir = await getTemporaryDirectory();
          final ts = DateTime.now().microsecondsSinceEpoch;
          final path = '${dir.path}/zhiban_poster_$ts.png';
          await File(path).writeAsBytes(image);
          await Gal.putImage(path);
        }
      }

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(total > 1 ? AppLocalizations.of(context)!.savedMultipleToAlbum(total) : AppLocalizations.of(context)!.savedToAlbum)),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.saveError(e.toString()))));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _sharePoster() async {
    final messenger = ScaffoldMessenger.of(context);
    final controllers = _controllers;

    setState(() => _isProcessing = true);
    try {
      await _waitForRender();

      final files = <XFile>[];
      for (int i = 0; i < controllers.length; i++) {
        final keyCtx = _posterKeys[i].currentContext;
        if (keyCtx != null) {
          // ignore: use_build_context_synchronously
          await Scrollable.ensureVisible(keyCtx,
              alignment: 0.0, duration: Duration.zero);
        }
        if (!mounted) return;
        await _waitForRender();

        final image = await controllers[i].capture(
          pixelRatio: _capturePixelRatio,
        );
        if (image != null) {
          files.add(
            XFile.fromData(
              image,
              name: 'zhiban_poster_$i.png',
              mimeType: 'image/png',
            ),
          );
        }
      }

      if (files.isNotEmpty) {
        await SharePlus.instance.share(
          ShareParams(files: files, text: AppLocalizations.of(context)!.posterFromApp),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.shareFailed(e.toString()))));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
