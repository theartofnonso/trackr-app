import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';

class OverlayBackground extends StatelessWidget {
  const OverlayBackground({super.key, this.loadingMessage, this.opacity = 0.7});

  final String? loadingMessage;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Container(
            width: double.infinity,
            height: double.infinity,
            color: sapphireDark.withOpacity(opacity),
            child: loadingMessage != null ? Center(child: Text("$loadingMessage", style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600))) : null));
  }
}