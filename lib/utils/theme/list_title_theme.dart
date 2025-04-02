import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TRKRListTileTheme {
  TRKRListTileTheme._();

  static ListTileThemeData lightTheme = ListTileThemeData(
      textColor: Colors.black,
      iconColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      titleTextStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
      subtitleTextStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.grey.shade600),
      leadingAndTrailingTextStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70));

  static ListTileThemeData darkTheme = ListTileThemeData(
    textColor: Colors.white,
    iconColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
    titleTextStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 14),
    subtitleTextStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70),
    leadingAndTrailingTextStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white70),
  );
}
