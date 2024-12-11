import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'trkr_coach_widget.dart';

class TRKRCoachButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const TRKRCoachButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle, // Use BoxShape.circle for circular borders
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.green.shade900], // Gradient colors
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(children: [
            const TRKRCoachWidget(),
            const SizedBox(width: 10),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, color: Colors.white70, fontSize: 14))
          ]),
        ),
      ),
    );
  }
}
