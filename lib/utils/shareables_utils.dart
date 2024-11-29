import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../colors.dart';
import '../widgets/buttons/opacity_button_widget.dart';
import 'dialog_utils.dart';

Future<ShareResult> captureImage({required GlobalKey key, required double pixelRatio}) async {
  final RenderRepaintBoundary boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
  final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List pngBytes = byteData!.buffer.asUint8List();
  final Directory tempDir = await getTemporaryDirectory();
  final File file = File('${tempDir.path}/${DateTime.now().microsecondsSinceEpoch}.png');
  final newFile = await file.writeAsBytes(pngBytes, flush: true);

  return await Share.shareUri(newFile.uri);
}

void onShare({required BuildContext context, required GlobalKey globalKey, EdgeInsetsGeometry? padding, required Widget child}) {
  displayBottomSheet(
      context: context,
      isScrollControlled: true,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
        RepaintBoundary(
            key: globalKey,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        sapphireDark80,
                        sapphireDark,
                      ],
                    ),
                  ),
                  padding: padding ?? const EdgeInsets.all(12),
                  child: child),
            )),
        const SizedBox(height: 20),
        OpacityButtonWidget(
            onPressed: () {
              Navigator.of(context).pop();
              captureImage(key: globalKey, pixelRatio: 5).then((result) {
                if (context.mounted) {
                  if (result.status == ShareResultStatus.success) {
                    showSnackbar(
                        context: context, icon: const FaIcon(FontAwesomeIcons.solidSquareCheck), message: "Content Shared");

                  }
                }
              });
            },
            label: "Share",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14))
      ]));
}
