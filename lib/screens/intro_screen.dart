import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors.dart';
import '../urls.dart';
import '../utils/uri_utils.dart';
import '../widgets/buttons/solid_button_widget.dart';

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
            'images/man_woman.jpg',
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
                'images/trkr.png',
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
                child: SolidButtonWidget(
                  onPressed: onComplete,
                  label: "Start training better",
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  buttonColor: vibrantGreen,
                  textColor: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: "Photo by".toUpperCase(),
                  style: GoogleFonts.montserrat(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                  children: <TextSpan>[
                    const TextSpan(text: " "),
                    TextSpan(
                      text: "Mikhail Nilov".toUpperCase(),
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                    const TextSpan(text: " "),
                    TextSpan(text: "on".toUpperCase()),
                    const TextSpan(text: " "),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          openUrl(url: pexelsImageUrl, context: context);
                        },
                      text: "Pexels".toUpperCase(),
                      style: GoogleFonts.montserrat(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w700,
                          fontSize: 10),
                    ),
                  ],
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
