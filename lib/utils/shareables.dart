import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

Future<void> captureImage({required GlobalKey key}) async {
  RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
  var image = await boundary.toImage(pixelRatio: 2.0);
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  Uint8List pngBytes = byteData.buffer.asUint8List();
}
