import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors.dart';

class NoList extends StatelessWidget {
  const NoList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
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
        child: SafeArea(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              const FaIcon(
                FontAwesomeIcons.house,
                color: Colors.white12,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text("It might feel quiet now, but new activities from fellow TRKR trainers will soon appear here.",
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
