import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';
import '../trkr_widgets/trkr_coach_widget.dart';

class TRKRCoachButton extends StatelessWidget {
  const TRKRCoachButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,  // Use BoxShape.circle for circular borders
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(children: [
            const TRKRCoachWidget(),
            const SizedBox(width: 10),
            Text("Ask TRKR coach",
                textAlign: TextAlign.center,
                style:
                GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70, fontSize: 14))
          ]),
        ),
      ),
    );
  }
}