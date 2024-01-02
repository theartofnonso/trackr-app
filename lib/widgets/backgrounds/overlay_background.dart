import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_constants.dart';

class OverlayBackground extends StatelessWidget {
  const OverlayBackground({super.key, required String loadingMessage}) : _loadingMessage = loadingMessage;

  final String _loadingMessage;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Container(
            width: double.infinity,
            height: double.infinity,
            color: tealBlueDark.withOpacity(0.7),
            child: Center(child: Text(_loadingMessage, style: GoogleFonts.montserrat(fontSize: 14)))));
  }
}