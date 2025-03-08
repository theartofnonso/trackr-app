

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class TRKRInformationContainer extends StatelessWidget {
  final String ctaLabel;
  final String description;
  final VoidCallback? onTap;
  final Widget? icon;

  const TRKRInformationContainer({super.key, required this.ctaLabel, required this.description, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle, // Use BoxShape.circle for circular borders
          gradient:  LinearGradient(
            colors: [Colors.blue.shade700, Colors.green.shade700], // Gradient colors
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                        description,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white, fontSize: 14)),
                  ),
                  const SizedBox(width: 22),
                  icon ?? FaIcon(FontAwesomeIcons.solidLightbulb, color: Colors.white,)
                ],),
              const SizedBox(height: 6),
              Text(
                  ctaLabel,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.ubuntu(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 14))
            ],
          ),
        ),
      ),
    );
  }
}