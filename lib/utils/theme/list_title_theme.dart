import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../colors.dart';

class TRKRListTileTheme {
  TRKRListTileTheme._();

  static ListTileThemeData lightTheme = ListTileThemeData(
    tileColor: Colors.grey.shade200,
      textColor: Colors.black,
    iconColor: Colors.black,
    titleTextStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.black),
    subtitleTextStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.black),
  );

  static ListTileThemeData darkTheme = ListTileThemeData(
      tileColor: sapphireDark80,
      textColor: Colors.white,
      iconColor: Colors.white,
    titleTextStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white),
    subtitleTextStyle: GoogleFonts.ubuntu(fontWeight: FontWeight.w400, color: Colors.white),
  );
}
