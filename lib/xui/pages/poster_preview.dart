import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application_zhiban/xui/pages/poster_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter/foundation.dart';

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
  final ScreenshotController _controller = ScreenshotController();

  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    final img = await _controller.captureFromWidget(
      Material(
        child: PosterWidget(item: widget.item),
      ),
    );

    setState(() {
      imageBytes = img;
    });
  }

  // ⭐ 下载逻辑（跨平台）
 Future<void> _download() async {
  if (imageBytes == null) return;

  await saveImage(imageBytes!);

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("已下载")),
    );
  }
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

          if (imageBytes == null)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(imageBytes!),
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