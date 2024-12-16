import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';

import '../../colors.dart';

GlobalKey twelveSessionMilestoneGlobalKey = GlobalKey();

class TwelveSessionMilestoneShareable extends StatelessWidget {
  final Image? image;

  const TwelveSessionMilestoneShareable({super.key, this.image});

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
          key: twelveSessionMilestoneGlobalKey,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? sapphireDark80 : Colors.grey.shade200,
              image: imageFile != null
                  ? DecorationImage(
                      image: imageFile.image,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isDarkMode ? sapphireDark.withOpacity(0.5) : Colors.grey.shade400,
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
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
                    Text("12 Sessions",
                        style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                    Text("You've closed the ring for ${DateTime.now().formattedFullMonth}",
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
