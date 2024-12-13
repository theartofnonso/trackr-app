import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TRKRTextTheme {
  TRKRTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    displaySmall: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.black),
    displayMedium: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.black),
    displayLarge: GoogleFonts.ubuntu(fontWeight: FontWeight.w900, color: Colors.black),

    headlineSmall: GoogleFonts.ubuntu(fontWeight: FontWeight.w900, color: Colors.black),
    headlineMedium: GoogleFonts.ubuntu(fontWeight: FontWeight.w900, color: Colors.black),
    headlineLarge: GoogleFonts.ubuntu(fontWeight: FontWeight.w900, color: Colors.black),

    titleSmall: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.black),
    titleMedium: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.black),
    titleLarge: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.black),

    labelSmall: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.black),
    labelMedium: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.black),
    labelLarge: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.black),

    bodySmall: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.black),
    bodyMedium: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, color: Colors.black),
    bodyLarge: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, color: Colors.black),
  );

  static TextTheme darkTextTheme = TextTheme(
    displaySmall: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white),
    displayMedium: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white),
    displayLarge: GoogleFonts.ubuntu(fontWeight: FontWeight.w900, color: Colors.white),

    headlineSmall: GoogleFonts.ubuntu(fontWeight: FontWeight.w900, color: Colors.white),
    headlineMedium: GoogleFonts.ubuntu(fontWeight: FontWeight.w900, color: Colors.white),
    headlineLarge: GoogleFonts.ubuntu(fontWeight: FontWeight.w900, color: Colors.white),

    titleSmall: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white),
    titleMedium: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.white),
    titleLarge: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.white),

    labelSmall: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white),
    labelMedium: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white),
    labelLarge: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.white),

    bodySmall: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white),
    bodyMedium: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, color: Colors.white),
    bodyLarge: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, color: Colors.white),
  );
}
