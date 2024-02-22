import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';

GlobalKey logMilestoneShareableKey = GlobalKey();

class LogMilestoneShareable extends StatelessWidget {
  final String label;
  final Image? image;

  const LogMilestoneShareable({super.key, required this.label, this.image});

  @override
  Widget build(BuildContext context) {
    final imageFile = image;

    return RepaintBoundary(
      key: logMilestoneShareableKey,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          image: imageFile != null
              ? DecorationImage(
                  image: imageFile.image,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                )
              : null,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          gradient: imageFile == null
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    sapphireDark80,
                    sapphireDark,
                  ],
                )
              : null,
        ),
        child: Stack(alignment: Alignment.center, fit: StackFit.expand, children: [
          if (imageFile != null)
            Positioned.fill(
                child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                  gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  sapphireDark.withOpacity(0.4),
                  sapphireDark,
                ],
              )),
            )),
          Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            const FaIcon(FontAwesomeIcons.award, color: vibrantGreen, size: 40),
            const SizedBox(height: 10),
            Text(label, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
            Text("Workout",
                style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Image.asset(
              'images/trackr.png',
              fit: BoxFit.contain,
              height: 8, // Adjust the height as needed
            ),
          ])
        ]),
      ),
    );
  }
}
