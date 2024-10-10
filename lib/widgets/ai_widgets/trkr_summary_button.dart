import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';

class TRKRSummaryButton extends StatelessWidget {

  const TRKRSummaryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              sapphireDark80,
              sapphireDark,
            ],
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "Completing a workout is an achievement, however consistent progress is what drives you toward your ultimate fitness goals.",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white, fontSize: 14)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {},
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.blue, Colors.green],
                    tileMode: TileMode.mirror,
                  ).createShader(Rect.fromLTWH(0.0, 0.0, bounds.width, bounds.height)),
                  child: Text("Review your feedback",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 14)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
