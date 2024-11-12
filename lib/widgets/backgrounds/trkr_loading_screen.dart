import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';

class TRKRLoadingScreen extends StatelessWidget {

  final double opacity;
  final VoidCallback? action;
  final List<String> messages;

  const TRKRLoadingScreen({super.key, this.opacity = 0.6, this.action, required this.messages});

  @override
  Widget build(BuildContext context) {
    final children = messages
        .map((message) => TypewriterAnimatedText(
              message,
              speed: Duration(milliseconds: 90),
              textStyle: GoogleFonts.ubuntu(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ))
        .toList();

    return Scaffold(
      body: Container(
          width: double.infinity,
          height: double.infinity,
          color: sapphireDark.withOpacity(opacity),
          child: Stack(
            children: [
              if (action != null)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SafeArea(
                      minimum: const EdgeInsets.all(10.0),
                      child: IconButton(
                        icon: const FaIcon(FontAwesomeIcons.solidCircleXmark, color: Colors.white, size: 28),
                        onPressed: action,
                      ),
                    ),
                  ),
                ),
              Center(
                child: AnimatedTextKit(
                  animatedTexts: children,
                  totalRepeatCount: 4,
                  pause: const Duration(milliseconds: 1000),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),
              ),
            ],
          )),
    );
  }
}
