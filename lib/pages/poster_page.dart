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
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            // 海报预览 — Clay 风
            Screenshot(
              controller: _screenshotController,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.ube800, AppTheme.ube900], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: AppTheme.oatBorder),
                  boxShadow: AppTheme.clayShadow,
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // 头部
                  Row(children: [
                    Text(widget.categoryIcon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    const Text('智伴口袋', style: TextStyle(color: AppTheme.pureWhite, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.4)),
                  ]),
                  const SizedBox(height: 32),
                  // 内容
                  Text(widget.content, style: const TextStyle(color: AppTheme.pureWhite, fontSize: 22, fontWeight: FontWeight.w500, height: 1.8)),
                  if (widget.title.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('— ${widget.title}', style: TextStyle(color: AppTheme.pureWhite.withValues(alpha: 0.8), fontSize: 16, fontStyle: FontStyle.italic)),
                  ],
                  if (widget.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(widget.subtitle, style: TextStyle(color: AppTheme.pureWhite.withValues(alpha: 0.6), fontSize: 14)),
                  ],
                  const SizedBox(height: 40),
                  Align(alignment: Alignment.centerRight, child: Text('每日知识陪伴', style: TextStyle(color: AppTheme.pureWhite.withValues(alpha: 0.5), fontSize: 12))),
                ]),
              ),
            ),

            const SizedBox(height: 24),

            // Clay 风格按钮
            Row(children: [
              Expanded(child: _clayBtn(Icons.download, _isProcessing ? '处理中...' : '保存相册', _isProcessing ? null : _savePoster)),
              const SizedBox(width: 16),
              Expanded(child: _clayBtn(Icons.share, '分享', _isProcessing ? null : _sharePoster)),
            ]),
          ]),
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
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: AppTheme.clayBlack),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppTheme.clayBlack, fontSize: 16, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  Future<bool> _requestPermission() async {
    if (Platform.isIOS) {
      return await Permission.photosAddOnly.request().isGranted || await Permission.photos.request().isGranted;
    }
    if (await Permission.storage.request().isGranted) return true;
    if (await Permission.photos.request().isGranted) return true;
    return true;
  }

  Future<void> _savePoster() async {
    setState(() => _isProcessing = true);
    try {
      final ok = await _requestPermission();
      if (!ok) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('需要相册权限')));
        return;
      }
      final image = await _screenshotController.capture(pixelRatio: 3.0);
      if (image != null) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/zhiban_poster_${DateTime.now().millisecondsSinceEpoch}.png';
        await File(path).writeAsBytes(image);
        await Gal.putImage(path);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 海报已保存至相册')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存出错: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _sharePoster() async {
    setState(() => _isProcessing = true);
    try {
      final image = await _screenshotController.capture(pixelRatio: 3.0);
      if (image != null) {
        await Share.shareXFiles(
          [XFile.fromData(image, name: 'zhiban_poster.png', mimeType: 'image/png')],
          text: '来自「智伴口袋」的每日知识分享',
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('分享失败: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}