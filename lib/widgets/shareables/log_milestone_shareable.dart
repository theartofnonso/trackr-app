import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';

GlobalKey logMilestoneShareableKey = GlobalKey();

class LogMilestoneShareable extends StatelessWidget {
  final String label;

  const LogMilestoneShareable({super.key, required this.label});

  @override
  Widget build(BuildContext context) {

    return RepaintBoundary(
      key: logMilestoneShareableKey,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
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
        width: MediaQuery.of(context).size.width - 20,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
        ]),
      ),
    );
  }
}
