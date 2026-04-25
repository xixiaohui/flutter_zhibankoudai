import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';

Future<void> saveImage(Uint8List bytes) async {
  final result = await ImageGallerySaver.saveImage(
    bytes,
    quality: 100,
    name: "poster_${DateTime.now().millisecondsSinceEpoch}",
  );

  print("保存结果: $result");
}