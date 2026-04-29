
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';

Future<bool> saveImage(Uint8List bytes) async {
  try {
    final hasAccess = await Gal.hasAccess();
    final granted = hasAccess || await Gal.requestAccess();

    if (!granted) {
      debugPrint("Save image denied: no gallery access");
      return false;
    }

    await Gal.putImageBytes(
      bytes,
      name: "poster_${DateTime.now().millisecondsSinceEpoch}",
    );
    return true;
  } on GalException catch (e) {
    debugPrint("Save image failed: ${e.type.message}");
    return false;
  } catch (e) {
    debugPrint("Save image failed: $e");
    return false;
  }
}
