

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';

class TRKRInformationContainer extends StatelessWidget {
  final String ctaLabel;
  final String description;
  final VoidCallback? onTap;

  const TRKRInformationContainer({super.key, required this.ctaLabel, required this.description, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle, // Use BoxShape.circle for circular borders
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.green], // Gradient colors
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          margin: const EdgeInsets.all(1), // Border width
          decoration: BoxDecoration(
            color: sapphireDark80,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    description,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white, fontSize: 14)),
                const SizedBox(height: 6),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.blue, Colors.green],
                    tileMode: TileMode.mirror,
                  ).createShader(Rect.fromLTWH(0.0, 0.0, bounds.width, bounds.height)),
                  child: Text(ctaLabel,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}