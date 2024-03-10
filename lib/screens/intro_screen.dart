import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors.dart';
import '../widgets/buttons/text_button_widget.dart';

class IntroScreen extends StatelessWidget {
  final ThemeData themeData;
  final VoidCallback onComplete;

  const IntroScreen({super.key, required this.themeData, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeData,
      home: Scaffold(
        body: Stack(alignment: Alignment.center, children: [
          Image.asset(
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            'images/man_in_dark.jpg',
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    sapphireDark.withOpacity(1),
                    sapphireDark.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const Spacer(),
              Image.asset(
                'images/trackr.png',
                fit: BoxFit.contain,
                height: 24, // Adjust the height as needed
              ),
              const SizedBox(height: 10),
              Text(
                "Train better".toUpperCase(),
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CTextButton(
                  onPressed: onComplete,
                  label: "Start training better",
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  buttonColor: vibrantGreen,
                  textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
            ]),
          )
        ]),
      ),
    );
  }
}
