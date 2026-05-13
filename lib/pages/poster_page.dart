import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';
import 'dart:io';
import '../config/theme.dart';

class PosterPage extends StatefulWidget {
  final String content;
  final String title;
  final String subtitle;
  final String categoryIcon;

  const PosterPage({
    super.key,
    required this.content,
    this.title = '',
    this.subtitle = '',
    this.categoryIcon = '',
  });

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

  static const _bodyStyle = TextStyle(
    color: AppTheme.pureWhite,
    fontSize: 44,
    fontWeight: FontWeight.w500,
    height: 1.9,
    letterSpacing: 0.3,
  );

  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _posterKeys = [];
  List<ScreenshotController> _controllers = [];
  List<String> _contentChunks = [];
  bool _isProcessing = false;

  String? _lastContent;
  String? _lastTitle;
  String? _lastSubtitle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recalculatePages();
  }

  @override
  void didUpdateWidget(PosterPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content ||
        oldWidget.title != widget.title ||
        oldWidget.subtitle != widget.subtitle ||
        oldWidget.categoryIcon != widget.categoryIcon) {
      _recalculatePages();
    }
  }

  void _recalculatePages() {
    if (_lastContent == widget.content &&
        _lastTitle == widget.title &&
        _lastSubtitle == widget.subtitle &&
        _controllers.isNotEmpty) {
      return;
    }
    _lastContent = widget.content;
    _lastTitle = widget.title;
    _lastSubtitle = widget.subtitle;

    final newChunks = _splitContent(widget.content);

    setState(() {
      _contentChunks = newChunks;
      _controllers =
          List.generate(newChunks.length, (_) => ScreenshotController());
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

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        title: const Text('生成海报'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isProcessing ? null : _sharePoster,
            tooltip: '分享海报',
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
                    _isProcessing ? '处理中...' : '保存相册',
                    _isProcessing ? null : _savePoster,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _clayBtn(
                    Icons.share,
                    '分享',
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
              Text(widget.categoryIcon, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              const Text(
                '智伴口袋',
                style: TextStyle(
                  color: AppTheme.pureWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Text(_contentChunks[pageIndex], style: _bodyStyle),
          if (isFirstPage && widget.title.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              '— ${widget.title}',
              style: TextStyle(
                color: AppTheme.pureWhite.withValues(alpha: 0.8),
                fontSize: 24,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (isFirstPage && widget.subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              widget.subtitle,
              style: TextStyle(
                color: AppTheme.pureWhite.withValues(alpha: 0.6),
                fontSize: 20,
              ),
            ),
          ],
          const SizedBox(height: 56),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '每日知识陪伴',
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
          messenger
              .showSnackBar(const SnackBar(content: Text('需要相册权限')));
        }
        setState(() => _isProcessing = false);
        return;
      }

      await _waitForRender();

      final total = controllers.length;
      for (int i = 0; i < total; i++) {
        if (mounted && total > 1) {
          messenger.showSnackBar(SnackBar(
            content: Text('保存中 ${i + 1}/$total...'),
            duration: const Duration(seconds: 1),
          ));
        }

        final keyCtx = _posterKeys[i].currentContext;
        if (keyCtx != null) {
          // ignore: use_build_context_synchronously
          await Scrollable.ensureVisible(keyCtx,
              alignment: 0.0, duration: Duration.zero);
        }
        if (!mounted) return;
        await _waitForRender();

        final image =
            await controllers[i].capture(pixelRatio: _capturePixelRatio);
        if (image != null) {
          final dir = await getTemporaryDirectory();
          final ts = DateTime.now().microsecondsSinceEpoch;
          final path = '${dir.path}/zhiban_poster_$ts.png';
          await File(path).writeAsBytes(image);
          await Gal.putImage(path);
        }
      }

      if (mounted) {
        messenger.showSnackBar(SnackBar(
          content: Text(
              total > 1 ? '$total 张海报已保存至相册' : '海报已保存至相册'),
        ));
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('保存出错: $e')));
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

        final image =
            await controllers[i].capture(pixelRatio: _capturePixelRatio);
        if (image != null) {
          files.add(XFile.fromData(
            image,
            name: 'zhiban_poster_$i.png',
            mimeType: 'image/png',
          ));
        }
      }

      if (files.isNotEmpty) {
        await SharePlus.instance.share(
          ShareParams(
            files: files,
            text: '来自「智伴口袋」的每日知识分享',
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('分享失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
