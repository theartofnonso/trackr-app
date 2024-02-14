import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

import '../colors.dart';

class IntroScreen extends StatelessWidget {
  final ThemeData themeData;
  final VoidCallback onComplete;

  const IntroScreen({super.key, required this.themeData, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeData,
      home: Scaffold(
        body: Container(
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
            minimum: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  Image.asset(
                    'images/trackr.png',
                    fit: BoxFit.contain,
                    height: 16, // Adjust the height as needed
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
          ),
        ),
      ),
    );
  }
}
