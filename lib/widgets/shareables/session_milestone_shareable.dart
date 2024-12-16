import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';

GlobalKey sessionMilestoneGlobalKey = GlobalKey();

class SessionMilestoneShareable extends StatelessWidget {
  final String label;
  final Image? image;

  const SessionMilestoneShareable({super.key, required this.label, this.image});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final imageFile = image;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: RepaintBoundary(
          key: sessionMilestoneGlobalKey,
          child: Container(
            decoration: BoxDecoration(
              image: imageFile != null
                  ? DecorationImage(
                      image: imageFile.image,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    )
                  : null,
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
                      gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      sapphireDark.withOpacity(0.4),
                      sapphireDark,
                    ],
                  )),
                )),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const FaIcon(FontAwesomeIcons.award, color: vibrantGreen, size: 40),
                    const SizedBox(height: 20),
                    Text(label,
                        style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                    Text("Session",
                        style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 30),
                    Image.asset(
                      'images/trkr.png',
                      fit: BoxFit.contain,
                      height: 8, // Adjust the height as needed
                    ),
                  ])
            ]),
          ),
        ),
      ),
    );
  }
}
