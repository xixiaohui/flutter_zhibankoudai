import 'dart:typed_data';
import 'package:gal/gal.dart';

Future<void> saveImage(Uint8List bytes) async {
  try {
    // 1️⃣ 检查权限
    final hasAccess = await Gal.hasAccess();

    if (!hasAccess) {
      final granted = await Gal.requestAccess();
      if (!granted) {
        print("❌ 用户拒绝权限");
        return;
      }
    }

    // 2️⃣ 保存图片
    await Gal.putImageBytes(
      bytes,
      name: "poster_${DateTime.now().millisecondsSinceEpoch}.png",
    );

    print("✅ 保存成功");
  } catch (e) {
    print("❌ 保存失败: $e");
  }
}