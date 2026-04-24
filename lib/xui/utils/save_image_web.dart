// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> saveImage(List<int> bytes) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "poster.png")
    ..click();

  html.Url.revokeObjectUrl(url);
}