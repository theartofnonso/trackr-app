import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> captureImage({required GlobalKey key, required double pixelRatio}) async {
  final RenderRepaintBoundary boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
  final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List pngBytes = byteData!.buffer.asUint8List();

  final Directory tempDir = await getTemporaryDirectory();
  final File file = File('${tempDir.path}/${DateTime.now().microsecondsSinceEpoch}.png');
  final newFile = await file.writeAsBytes(pngBytes, flush: true);

  await Share.shareUri(newFile.uri);
}
