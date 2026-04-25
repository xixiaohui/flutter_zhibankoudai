import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  @override
  void initState() {
    super.initState();

    // ⭐ 等 UI 渲染完再截图（关键）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _capture();
    });
  }

  /// ⭐ 核心截图方法
  Future<void> _capture() async {
    try {
      final boundary =
          posterKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // ⭐ 确保已渲染
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 100));
        return _capture();
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      final bytes = byteData?.buffer.asUint8List();

      if (!mounted) return;

      setState(() {
        imageBytes = bytes;
      });
    } catch (e) {
      debugPrint("❌ 导出失败: $e");
    }
  }

  /// ⭐ 下载
  Future<void> _download() async {
    if (imageBytes == null) return;

    await saveImage(imageBytes!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("已下载")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),

          const Text(
            "海报预览",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          /// ⭐ 关键：必须包 RepaintBoundary
          RepaintBoundary(
            key: posterKey,
            child: Container(
              color: Colors.white, // ⭐ 避免透明背景影响截图
              child: PosterWidget(item: widget.item),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("关闭"),
              ),
              ElevatedButton(
                onPressed: _download,
                child: const Text("下载"),
              ),
            ],
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}