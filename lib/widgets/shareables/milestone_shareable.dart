import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/milestones/milestone_dto.dart';

import '../../colors.dart';

GlobalKey milestoneGlobalKey = GlobalKey();

class MilestoneShareable extends StatelessWidget {
  final GlobalKey? globalKey;
  final Milestone milestone;
  final Image? image;

  const MilestoneShareable({super.key, this.globalKey, required this.milestone, this.image});

  @override
  Widget build(BuildContext context) {
    final imageFile = image;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: RepaintBoundary(
          key: globalKey,
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
                  ? LinearGradient(
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
                      sapphireDark.withValues(alpha: 0.4),
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
                    Text(milestone.name,
                        style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                    Text(milestone.caption,
                        style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 50),
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
