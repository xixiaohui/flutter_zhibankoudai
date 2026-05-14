import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_zhiban/design/colors.dart';
import 'package:flutter_application_zhiban/xui/pages/poster_widget.dart';

import 'package:flutter_application_zhiban/xui/utils/save_image_stub.dart'
    if (dart.library.html) 'package:flutter_application_zhiban/xui/utils/save_image_web.dart'
    if (dart.library.io) 'package:flutter_application_zhiban/xui/utils/save_image_mobile.dart';

class PosterPreview extends StatefulWidget {
  final Map item;

  const PosterPreview({super.key, required this.item});

  @override
  State<PosterPreview> createState() => _PosterPreviewState();
}

class _PosterPreviewState extends State<PosterPreview> {
  final GlobalKey posterKey = GlobalKey();
  Uint8List? imageBytes;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _capture());
  }

  /// 等待 RenderRepaintBoundary 布局绘制完成
  Future<bool> _waitForLayout() async {
    final boundary = posterKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return false;

    // 等待帧结束，确保布局完成
    int retries = 0;
    while (boundary.debugNeedsPaint && retries < 10) {
      await WidgetsBinding.instance.endOfFrame;
      retries++;
    }
    if (boundary.debugNeedsPaint) return false;

    // 额外检查：确保尺寸非零
    if (boundary.size.width <= 0 || boundary.size.height <= 0) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (boundary.size.width <= 0 || boundary.size.height <= 0) return false;
    }
    return true;
  }

  Future<void> _capture() async {
    // 先获取像素比，避免跨 async 使用 context
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    try {
      final ready = await _waitForLayout();
      if (!ready) {
        await Future.delayed(const Duration(milliseconds: 200));
        final retry = await _waitForLayout();
        if (!retry) return;
      }

      final boundary = posterKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();

      if (!mounted) return;
      setState(() => imageBytes = bytes);
    } catch (e) {
      debugPrint("Export poster failed: $e");
    }
  }

  Future<void> _download() async {
    if (imageBytes == null || saving) return;

    // 提前获取 messenger，避免跨 async 使用 context
    final messenger = ScaffoldMessenger.of(context);
    setState(() => saving = true);

    final ok = await saveImage(imageBytes!);

    if (!mounted) return;
    setState(() => saving = false);

    messenger.showSnackBar(
      SnackBar(content: Text(ok ? "已保存到相册" : "保存失败，请检查相册权限")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final maxPreviewWidth = (screen.width - 48).clamp(280.0, 420.0).toDouble();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text("海报预览", style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  tooltip: "关闭",
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 海报预览 — 可滚动查看完整内容，RepaintBoundary 捕获全高
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: maxPreviewWidth,
                    child: RepaintBoundary(
                      key: posterKey,
                      child: Container(
                        color: AppColors.pureWhite,
                        child: PosterWidget(item: widget.item),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 底部按钮
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: imageBytes == null || saving ? null : _download,
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text(imageBytes == null ? "生成中..." : "保存到相册"),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blueberry800,
                  foregroundColor: AppColors.pureWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
