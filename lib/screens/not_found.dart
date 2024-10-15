import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../colors.dart';

class NotFound extends StatelessWidget {
  const NotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: sapphireDark80,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
          onPressed: context.pop,
        ),
      ),
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
            child: Center(
              child: RichText(
                  text: TextSpan(
                      style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white),
                      children: [
                        TextSpan(
                            text: "Not F",
                            style: GoogleFonts.ubuntu(fontSize: 28, color: Colors.white70, fontWeight: FontWeight.w900)),
                        const WidgetSpan(
                            child: Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 28, color: Colors.white70),
                            ),
                            alignment: PlaceholderAlignment.middle),
                        TextSpan(
                            text: "und",
                            style: GoogleFonts.ubuntu(fontSize: 28, color: Colors.white70, fontWeight: FontWeight.w900)),
                      ])),
            )),
      ),
    );
  }
}
