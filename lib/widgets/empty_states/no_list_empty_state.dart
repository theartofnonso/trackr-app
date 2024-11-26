import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';

class NoListEmptyState extends StatelessWidget {

  final Widget? icon;
  final String message;

  const NoListEmptyState({super.key, this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: SafeArea(
            minimum: const EdgeInsets.all(10.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon ?? FaIcon(FontAwesomeIcons.solidLightbulb, size: 38, color: Colors.white38),
                  const SizedBox(height: 16),
                  Text(message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ubuntu(
                          color: Colors.white38,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600))
                ])),
      ),
    );
  }
}
