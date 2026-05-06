import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_zhiban/xui/pages/poster_widget.dart';
import 'package:flutter_application_zhiban/xui/x_design.dart' as xui;

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

  Future<void> _capture() async {
    try {
      final context = posterKey.currentContext;
      if (context == null) return;

      final boundary = context.findRenderObject() as RenderRepaintBoundary;
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 80));
        return _capture();
      }

      final image = await boundary.toImage(pixelRatio: 3);
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

    setState(() => saving = true);
    final ok = await saveImage(imageBytes!);

    if (!mounted) return;
    setState(() => saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
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
                  child: Text(
                    "海报预览",
                    style: xui.XuiTheme.featureTitle(),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  tooltip: "关闭",
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: SizedBox(
                width: maxPreviewWidth,
                child: RepaintBoundary(
                  key: posterKey,
                  child: Container(
                    color: xui.XuiTheme.pureWhite,
                    child: PosterWidget(item: widget.item),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                  backgroundColor: xui.XuiTheme.blueberry800,
                  foregroundColor: xui.XuiTheme.pureWhite,
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
